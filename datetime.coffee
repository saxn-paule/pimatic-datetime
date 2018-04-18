module.exports = (env) ->

	Promise = env.require 'bluebird'
	t = env.require('decl-api').types
	Moment = require 'moment-timezone'

	class DateTimePlugin extends env.plugins.Plugin
		init: (app, @framework, @config) =>

			deviceConfigDef = require("./device-config-schema")

			@framework.deviceManager.registerDeviceClass("DateTimeDevice", {
				prepareConfig: DateTimeDevice.prepareConfig,
				configDef : deviceConfigDef.DateTimeDevice,
				createCallback : (config, lastState) => new DateTimeDevice(config, lastState, this )
			})

	class DateTimeDevice extends env.devices.Device
		attributes:
			dayOfWeek:
				description: 'the current day of the week (localized)'
				type: t.number
			dayOfMonth:
				description: 'the current day of the week'
				type: t.number
			dayOfYear:
				description: 'the current day of the year'
				type: t.number
			week:
				description: 'the weeknumber of the year'
				type: t.number
			weekend:
				description: 'time to party?'
				type: t.string
			time:
				description: 'localized time'
				type: t.string
			date:
				description: 'localized date'
				type: t.string
			datetime:
				description: 'localized datetime'
				type: t.string
			formatted:
				description: 'formatted datetime by given datetime format'
				type: t.string
			unixTimestamp:
				description: 'unix timestamp'
				type: t.number
			difference:
				description: 'difference between reference and current date(time)'
				type: t.number


		@prepareConfig: (config) =>
			numericAttributes = ['dayOfWeek', 'dayOfMonth', 'dayOfYear', 'week', 'unixTimestamp']
			xAttributeOptions = config.xAttributeOptions

			keys = []
			for i in xAttributeOptions
				keys.push(i.name)

			# set displaySparkline to false initially
			for attr in numericAttributes
				if attr not in keys
					xAttributeOptions.push(
						{
							name: attr,
							displaySparkline: false
						}
					)

			config.xAttributeOptions = xAttributeOptions


		constructor: (@config, @plugin, lastState) ->
			# provide possibility to add labels
			for attribute in @config.attributes
				do (attribute) =>
					label = attribute.name.replace /(^[a-z])|([A-Z])/g, ((match, p1, p2, offset) =>
						(if offset > 0 then " " else "") + match.toUpperCase())
					@attributes[attribute.name] =
						description: label
						type: "string"
						acronym: attribute.label ? label

			# create getter function for attributes
			for attributeName of @attributes
				do (attributeName) =>
					@_createGetter(attributeName, =>
						@initialized.then => Promise.resolve @[attributeName]
					)

			@id = @config.id
			@name = @config.name
			@interval = @config.interval || 5000
			@locale = @config.locale || 'de'
			@dateformat = @config.dateformat
			@timezone = @config.timezone
			@referenceDate = @config.referenceDate
			@differenceFormat = @config.differenceFormat || "days"

			@dayOfWeek = lastState?["dayOfWeek"]?.value or -1
			@dayOfMonth = lastState?["dayOfMonth"]?.value or -1
			@dayOfYear = lastState?["dayOfYear"]?.value or -1
			@week = lastState?["week"]?.value or -1
			@time = lastState?["time"]?.value or -""
			@date = lastState?["date"]?.value or -""
			@datetime = lastState?["datetime"]?.value or ""
			@formatted = lastState?["formatted"]?.value or ""
			@unixTimestamp = lastState?["unixTimestamp"]?.value or -1
			@weekend = lastState?["weekend"]?.value or ""

			@initialized = new Promise (resolve) =>
				@_reloadDateTimes()
				resolve()

			@timerId = setInterval ( =>
				@_reloadDateTimes()
			), @interval
			super(@config)


		_setAttribute: (attributeName, value) ->
			@emit attributeName, value
			@[attributeName] = value


		_reloadDateTimes: ->
			currentDate = new Date()
			@_setAttribute "unixTimestamp", currentDate.getTime()

			moment = Moment(currentDate)

			if @timezone?
				moment.tz(@timezone)

			if @locale
				moment.locale(@locale)

			@_setAttribute "dayOfWeek", moment.weekday() + 1
			@_setAttribute "dayOfMonth", moment.date()
			@_setAttribute "dayOfYear", moment.dayOfYear()
			@_setAttribute "week", moment.week()
			@_setAttribute "time", moment.format('HH:mm')
			@_setAttribute "date", moment.format('L')
			@_setAttribute "datetime", @date + " " + @time

			if @dateformat?
				@_setAttribute "formatted", moment.format(@dateformat)
			else
				@_setAttribute "formatted", moment.format()

			if moment.isoWeekday() > 5
				@_setAttribute "weekend", 'true'
			else
				@_setAttribute "weekend", 'false'

			### Calculate differences ###
			if @referenceDate
				refDate = Moment(@referenceDate)

				if @timezone?
					refDate.tz(@timezone)

				if @locale
					refDate.locale(@locale)

				diff = refDate.diff(currentDate)

				switch @differenceFormat
					when "days"
						diff = diff / 86400000
					when "hours"
						diff = diff / 3600000
					when "minutes"
						diff = diff / 60000
					when "seconds"
						diff = diff / 1000
					else
						diff = diff

				@_setAttribute "difference", Math.round(diff)

		destroy: () ->
			if @timerId?
				clearInterval @timerId
				@timerId = null
			super()

	return new DateTimePlugin
