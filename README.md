tostify
=======

*(read like "testify" with an "o")*

Do you read the TOS of services you use? Do you with to keep track of their changes? This may be the script for you. This can also be used to keep track of pretty much any change on any webpage. We're using git + ruby to download the current state and compare it with the "last known" state.


Configuration
-------------

After cloning this project, you should create a branch of your own like this:

    git checkout -b mytos

Toss one json-file into the services directory, specifying the sites and their respective urls. We're using [ToS;DR's specification](https://github.com/tosdr/tosdr.org/wiki/Specification:-services), which means, you can easily choose from ToS;DR's very large [list of defined services](https://github.com/tosdr/tosdr.org/tree/master/services) - or just write your own.

For this script, we really only take the id and any url we can find. The minimum specification therefore becomes this:

    {
      "id": "facebook",
      "name": "Facebook",
      "tosback2": {
        "privacy": {
          "name": "Data Use Policy",
          "url": "http://www.facebook.com/full_data_use_policy"
        },
        /* maybe other urls besides that (yes, i know, comment isn't valid json) */
      }
    }

In addition to that spec, we're also adding a CSS-Selector, which tells us where exactly the text can be found. Adding that, the above example looks like this:

    {
      "id": "facebook",
      "name": "Facebook",
      "tosback2": {
        "privacy": {
          "name": "Data Use Policy",
          "url": "http://www.facebook.com/full_data_use_policy",
          "selector": "div.maia-article"
        }
      }
    }

If you're using the selector, we'll only convert that part of the page to text and put it in your git repository.


Put this into your crontab to check all your configured sites every night:

    0 5 * * * /path/to/tostify/tostify.rb


Requirements
------------

Developed for Ruby 1.9+ and pretty much any version of git. Git must be on your path.


Note to windows users
---------------------

On Windows, you can use "Scheduled Tasks" instead of crontab to automate downloads. To install hpricot (used in this project), you'll need the [RubyDevKit](http://rubyinstaller.org/downloads/)
