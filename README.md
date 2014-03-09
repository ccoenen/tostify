tostify
=======

*(read like "testify" with an "o")*

Do you read the TOS of services you use? Do you with to keep track of their changes? This may be the script for you. This can also be used to keep track of pretty much any change on any webpage. We're using git + ruby to download the current state and compare it with the "last known" state.

Usage
-----

Add a simple line of config to the pages section of `config.json`. This will look like this:

    {
        "url": "https://www.google.de/intl/de/policies/terms/regional.html"
    }

Afterwards, the script will download that page to a directory called `www.google.de` below `history`. The directory name can be configured like in this example, where the downloaded file will end up in a directory called `Google`.

    {
	    "name": "Google",
        "url": "https://www.google.de/intl/de/policies/terms/regional.html"
    }


Put this into your crontab to check all your configured sites every night:

    0 5 * * * /path/to/tostify/tostify.rb

Requirements
------------

Developed for Ruby 1.9+ and pretty much any version of git. Git must be on your path.

Note to windows users
---------------------

On Windows, you can use "Scheduled Tasks" instead of crontab to automate downloads. To install hpricot (used in this project), you'll need the [RubyDevKit](http://rubyinstaller.org/downloads/)
