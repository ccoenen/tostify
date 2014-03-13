tostify
=======

*(read like "testify" with an "o")*

Do you read the TOS of services you use? Do you with to keep track of their changes? This may be the script for you. This can also be used to keep track of pretty much any change on any webpage. The script downloads the specified URLs to a markdown-like format on your hard disk.

We're using git + ruby to download the current state and compare it with the "last known" state. The markdown transformation could probably be improved, but it is quite reasonable output for most sites already.

Configuration
-------------

There's three ways to configure this script, which may also be mixed:

* [tostify config files](rules/readme.md)
* [tosback2 rules](tosback2-rules/readme.md)
* [tosdr services](tosdr-services/readme.md)

A lot of websites / services are already defined as by tosback2 and ToS;DR, so you may want to look
at these options before creating your own rules.

After cloning this project, you should create a branch of your own like this:

    git checkout -b mytos

If you're using the selector, we'll only convert that part of the page to text and put it in your
git repository.


Running
-------

### Runinning the script manually

The bundle exec makes sure, the right dependencies are being used.

    bundle exec ruby tostify.rb

### Running with lots of debug output

    bundle exec ruby -d tostify.rb

### Running from crontab

Running from crontab is a little trickier. Bundle depends on your environment being set up, so we
need to put something longer into the crontab. The example belongs in the user crontab (edit with
`crontab -e`) and will check for changes every morning.

    0 5 * * * bash -l -c 'cd /path/to/tostify; bundle exec ruby tostify.rb'

### Sending notification mail from crontab

Crontab can send mail with the `MAILTO=your-mail@example.com` config line. However, this will give
not work too well, as the encoding of this script and its output is utf-8. Here, we're piping the
output into mail, giving it a `Content-Type` header. Make sure you put your own email-adress at the
end.

    0 5 * * *  bash -l -c 'cd /path/to/tostify; bundle exec ruby tostify.rb' | mail -a "Content-Type: text/plain; charset=UTF-8" -s "TOStify" your-mail@example.com


Current State
-------------

The script is pretty robust, it ran through all of the available tosback2-rules and tos;dr-services
without any major problems.


Requirements
------------

Developed for Ruby 1.9+ and pretty much any version of git. Git must be on your path.


Note to windows users
---------------------

On Windows, you can use "Scheduled Tasks" instead of crontab to automate downloads. To install
hpricot (used in this project), you'll need the [RubyDevKit](http://rubyinstaller.org/downloads/)
