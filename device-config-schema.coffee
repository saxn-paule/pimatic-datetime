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
				default: "DE"
			timezone:
				description: "the timezone"
				type: "string"
				default: ""
			dateformat:
				description: "date / datetime format e.g. YYYY-MM-dd HH:mm:SS"
				type: "string"
				default: ""
	}
}
