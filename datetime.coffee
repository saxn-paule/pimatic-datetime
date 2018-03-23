module.exports = (env) ->

	Promise = env.require 'bluebird'
	assert = env.require 'cassert'
	_ = require 'lodash'
	M = env.matcher
	t = env.require('decl-api').types
	Moment = require 'moment-timezone'

	class DateTimePlugin extends env.plugins.Plugin
		init: (app, @framework, @config) =>

			deviceConfigDef = require("./device-config-schema")

			@framework.deviceManager.registerDeviceClass("DateTimeDevice",{
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
			time:
				description: 'localized time'
				type: t.string
			date:
				description: 'localized date'
				type: t.string
			datetime:
				description: 'flocalized datetime'
				type: t.string
			formatted:
				description: 'formatted datetime by given datetime format'
				type: t.string
			unixTimestamp:
				description: 'unix timestamp'
				type: t.number


		constructor: (@config, @plugin, lastState) ->
			@id = @config.id
			@name = @config.name
			@interval = @config.interval || 5000
			@locale = @config.locale || 'de'
			@dateformat = @config.dateformat
			@timezone = @config.timezone

			@dayOfWeek = lastState?["dayOfWeek"]?.value or -1
			@dayOfMonth = lastState?["dayOfMonth"]?.value or -1
			@dayOfYear = lastState?["dayOfYear"]?.value or -1
			@week  = lastState?["week"]?.value or -1
			@time = lastState?["time"]?.value or -""
			@date = lastState?["date"]?.value or -""
			@datetime = lastState?["datetime"]?.value or ""
			@formatted = lastState?["formatted"]?.value or ""
			@unixTimestamp = lastState?["unixTimestamp"]?.value or -1

			@reloadDateTimes()

			@timerId = setInterval ( =>
				@reloadDateTimes()
			), (@interval)

			updateValues = =>
				if @interval > 0
					@_updateValueTimeout = null
					@_getUpdatedDayOfMonth().finally( =>
						@_getUpdatedDayOfWeek().finally( =>
							@_getUpdatedDayOfYear().finally( =>
								@_getUpdatedTime().finally( =>
									@_getUpdatedWeek().finally( =>
										@_getUpdatedDate().finally( =>
											@_getUpdatedDatetime().finally( =>
												@_getUpdatedFormatted().finally( =>
													@_getUpdatedUnixTimestamp().finally( =>
														@_updateValueTimeout = setTimeout(updateValues, @interval)
													)
												)
											)
										)
									)
								)
							)
						)
					)

			super()
			updateValues()

		getDayOfMonth: ->
			if @dayOfMonth? then Promise.resolve(@dayOfMonth)
			else @_getUpdatedDayOfMonth("dayOfMonth")

		getDayOfWeek: ->
			if @dayOfWeek? then Promise.resolve(@dayOfWeek)
			else @_getUpdatedDayOfWeek("dayOfWeek")

		getDayOfYear: ->
			if @dayOfYear? then Promise.resolve(@dayOfYear)
			else @_getUpdatedDayOfYear("dayOfYear")

		getTime: ->
			if @time? then Promise.resolve(@time)
			else @_getUpdatedTime("time")

		getWeek: ->
			if @week? then Promise.resolve(@week)
			else @_getUpdatedWeek("week")

		getDate: ->
			if @date? then Promise.resolve(@date)
			else @_getUpdatedDate("date")

		getDatetime: ->
			if @datetime? then Promise.resolve(@datetime)
			else @_getUpdatedDatetime("datetime")

		getFormatted: ->
			if @formatted? then Promise.resolve(@formatted)
			else @_getUpdatedFormatted("formatted")

		getUnixTimestamp: ->
			if @unixTimestamp? then Promise.resolve(@unixTimestamp)
			else @_getUpdatedUnixTimestamp("unixTimestamp")


		_getUpdatedDayOfMonth: () =>
			@emit "dayOfMonth", @dayOfMonth
			return Promise.resolve @dayOfMonth

		_getUpdatedDayOfWeek: () =>
			@emit "dayOfWeek", @dayOfWeek
			return Promise.resolve @dayOfWeek

		_getUpdatedDayOfYear: () =>
			@emit "dayOfYear", @dayOfYear
			return Promise.resolve @dayOfYear

		_getUpdatedTime: () =>
			@emit "time", @time
			return Promise.resolve @time

		_getUpdatedWeek: () =>
			@emit "week", @week
			return Promise.resolve @week

		_getUpdatedDate: () =>
			@emit "date", @date
			return Promise.resolve @date

		_getUpdatedDatetime: () =>
			@emit "datetime", @datetime
			return Promise.resolve @datetime

		_getUpdatedFormatted: () =>
			@emit "formatted", @formatted
			return Promise.resolve @formatted

		_getUpdatedUnixTimestamp: () =>
			@emit "unixTimestamp", @unixTimestamp
			return Promise.resolve @unixTimestamp


		reloadDateTimes: ->
			currentDate = new Date()
			@unixTimestamp = currentDate.getTime()

			moment = Moment(currentDate)

			if @timezone?
				moment.tz(@timezone)

			if @locale
				moment.locale(@locale)

			@dayOfWeek = moment.weekday() + 1
			@dayOfMonth = moment.date()
			@dayOfYear = moment.dayOfYear()
			@week = moment.week()
			@time = moment.format('HH:mm')
			@date = moment.format('L')
			@datetime = @date + " " + @time

			if @dateformat?
				@formatted = moment.format(@dateformat)
			else
				@formatted = moment.format()

		destroy: () ->
			if @timerId?
				clearInterval @timerId
				@timerId = null

			clearTimeout @_updateValueTimeout if @_updateValueTimeout?
			super()

	return new DateTimePlugin
