# Tostify rules

This directory takes tostify's own rule files as either json or txt.

They generally have this form, and may contain these attributes:

    {
        "name": "example",
        "url": "http://example.com",
        "css": "#faq",
        "xpath": "//div"
    }

* `name` is optional and will default to the name of the config file.
* `url` is required and should be a full url including http(s)://
* `css` is optional and takes a css-selector from which we'll take the content
* `xpath` is optional and takes an xpath from which we'll take the content

Please note that `css` takes precedence over `xpath` in case both are present.

The minimum config is this:

    "http://example.com"

In which case the string is interpreted as url and the other attributes will default
as described above. The quotes are mandatory, otherwise this wouldn't be valid JSON.
