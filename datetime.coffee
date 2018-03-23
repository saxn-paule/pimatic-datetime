module.exports = (env) ->

	Promise = env.require 'bluebird'
	assert = env.require 'cassert'
	_ = require 'lodash'
	M = env.matcher
	t = env.require('decl-api').types
	Moment = require 'moment'

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
			locTime:
				description: 'localized time'
				type: t.string
			locDate:
				description: 'localized date'
				type: t.string
			locDatetime:
				description: 'flocalized datetime'
				type: t.string
			datetime:
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

			@dayOfWeek = lastState?["dayOfWeek"]?.value or -1
			@dayOfMonth = lastState?["dayOfMonth"]?.value or -1
			@locTime = lastState?["locTime"]?.value or -""
			@locDate = lastState?["locDate"]?.value or -""
			@locDatetime = lastState?["locDatetime"]?.value or ""
			@datetime = lastState?["datetime"]?.value or ""
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
							@_updateValueTimeout = setTimeout(updateValues, @interval)
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

		getLocTime: ->
			if @locTime? then Promise.resolve(@locTime)
			else @_getUpdatedLocTime("locTime")

		getLocDate: ->
			if @locDate? then Promise.resolve(@locDate)
			else @_getUpdatedLocDate("locDate")

		getLocDatetime: ->
			if @locDatetime? then Promise.resolve(@locDatetime)
			else @_getUpdatedLocDatetime("locDatetime")

		getDatetime: ->
			if @datetime? then Promise.resolve(@datetime)
			else @_getUpdatedDatetime("datetime")

		getUnixTimestamp: ->
			if @unixTimestamp? then Promise.resolve(@unixTimestamp)
			else @_getUpdatedUnixTimestamp("unixTimestamp")


		_getUpdatedDayOfMonth: () =>
			@emit "dayOfMonth", @dayOfMonth
			return Promise.resolve @dayOfMonth

		_getUpdatedDayOfWeek: () =>
			@emit "dayOfWeek", @dayOfWeek
			return Promise.resolve @dayOfWeek

		_getUpdatedLocTime: () =>
			@emit "locTime", @locTime
			return Promise.resolve @locTime

		_getUpdatedLocDate: () =>
			@emit "locDate", @locDate
			return Promise.resolve @locDate

		_getUpdatedLocDatetime: () =>
			@emit "locDatetime", @locDatetime
			return Promise.resolve @locDatetime

		_getUpdatedDatetime: () =>
			@emit "datetime", @datetime
			return Promise.resolve @datetime

		_getUpdatedUnixTimestamp: () =>
			@emit "unixTimestamp", @unixTimestamp
			return Promise.resolve @unixTimestamp


		reloadDateTimes: ->
			currentDate = new Date()
			@unixTimestamp = currentDate.getTime()

			moment = Moment(currentDate)

			@dayOfMonth = moment.date()
			@dayOfWeek = moment.weekday()
			if @dateformat?
				@datetime = moment.format(@dateformat)
			else
				@datetime = moment.format()

			locMoment = Moment(currentDate)
			locMoment.locale(@locale)
			@locTime = locMoment.format('HH:mm')
			@locDate =
			@locDatetime = locMoment.format('L')


		destroy: () ->
			if @timerId?
				clearInterval @timerId
				@timerId = null

			clearTimeout @_updateValueTimeout if @_updateValueTimeout?
			super()

	return new DateTimePlugin
