# ToS;DR-Style Configs

This directory takes ToS;DR's services files.

* [ToS;DR's specification](https://github.com/tosdr/tosdr.org/wiki/Specification:-services) How the format works
* [ToS;DR's services](https://github.com/tosdr/tosdr.org/tree/master/services) Lots of definitions you can just use.

They generally have this form, and may contain more attributes:

    {
      "name": "Human Readable Name",
      "tosback2": {
        "terms": {
          "name": "Name of this Block, i.e. terms",
          "url": "http://www.example.com/terms/of/service"
        }
      }
    }

I also read one more "optional" key, that's called "selector". This is a
CSS selector of the element contaning the actual text. Defaults to "body". 
Those selectors would have to be added manually, though, as they are not
standardized.

    {
      "name": "Human Readable Name",
      "tosback2": {
        "terms": {
          "name": "Name of this Block, i.e. terms",
          "url": "http://www.example.com/terms/of/service",
          "selector": "div#content"
        }
      }
    }
