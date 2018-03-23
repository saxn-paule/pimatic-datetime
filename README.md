# Description
### This plugin provides date and time information

# Configuration
### Sample Plugin Config:
```javascript
{
  "plugin": "datetime"
}
```

### Sample Device Config:
There are two optional configuration parameters
* locale - is used for formatting the local variables
* dateformat - is used for formatting the datetime variable

```javascript
    {
      "name": "datetime",
      "class": "DateTimeDevice",
      "xAttributeOptions": [],
      "id": "datetime",
      "locale": "en-US",
      "dateformat": "YYYY-MM-DD"
    }
```

# Beware
This plugin is in an early alpha stadium and you use it on your own risk.
I'm not responsible for any possible damages that occur on your health, hard- or software.

# License
MIT