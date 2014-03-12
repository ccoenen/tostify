This directory takes tos;dr's services files. Those can be found here:
https://github.com/tosdr/tosdr.org/tree/master/services



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
