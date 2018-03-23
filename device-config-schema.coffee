# datetime plugin configuration options
module.exports = {
	title: "datetime"
	DateTimeDevice :{
		title: "Plugin Properties"
		type: "object"
		extensions: ["xLink", "xAttributeOptions"]
		properties:
			locale:
				description: "the iso code"
				type: "string"
				default: "DE"
			dateformat:
				description: "date / datetime format e.g. YYYY-MM-dd HH:mm:SS"
				type: "string"
				default: ""
	}
}
