# datetime plugin configuration options
module.exports = {
	title: "datetime"
	DateTimeDevice :{
		title: "Plugin Properties"
		type: "object"
		extensions: ["xLink", "xAttributeOptions"]
		properties:
			interval:
				description: "refresh interval in ms"
				type: "number"
				default: 5000
			locale:
				description: "the iso code"
				type: "string"
				default: "de"
			timezone:
				description: "the timezone"
				type: "string"
				default: ""
			dateformat:
				description: "date / datetime format e.g. YYYY-MM-dd HH:mm:ss"
				type: "string"
				default: ""
			referenceDate:
				description: "a fix reference date for date calculations. Format: YYYY-MM-dd HH:mm:ss"
				type: "string"
				default: ""
			differenceFormat:
				description: "the format for date calculation differences [days|hours|minutes|seconds]"
				type: "string"
				default: "days"
			attributes:
				description: "Attributes which shall be exposed by the device"
				type: "array"
				default: []
				format: "table"
				items:
					type: "object"
					properties:
						name:
							enum: [
								"dayOfWeek", "dayOfMonth", "dayOfYear", "week", "weekend", "time", "date", "datetime", "formatted", "unixTimestamp"
							]
							description: "datetime related attributes"
						label:
							type: "string"
							description: "The attribute label text to be displayed. The name will be displayed if not set"
							required: false
	}
}
