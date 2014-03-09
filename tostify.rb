#!/usr/bin/env ruby
# The MIT License (MIT)
# Copyright (c) 2014 Claudius Coenen
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# encoding: UTF-8
Encoding.default_external = Encoding::UTF_8 if RUBY_VERSION > '1.8.7'

require 'json'
require 'uri'
require 'net/http'
require 'fileutils'
require 'hpricot'
require 'chromatic'

Dir.chdir(File.dirname(__FILE__))
CONFIG = JSON.load(File.open('config.json', 'r'))

# get all the config files for the various services
configured_services = Dir[File.join(CONFIG['services'], '*.json')]
@changed_services = []


#
# High level functions start here
#


# retrieves the utf-8 encoded request body for uri
def retrieve_request_body uri
  http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == 'https'
    http.use_ssl = true
    http.ca_file = "cacert.pem"
  end

  response = http.get(uri.path)
  if response["Content-Type"] =~ /charset=(.*)$/
    response.body.force_encoding($1)
  else
    response.body.force_encoding('UTF-8')
  end
  puts "#{uri} (HTTP #{response.code}, #{response.body.length} Bytes)".yellow
  unless response.code == "200"
    puts "WARNING: Response code was #{response.code}".red
  end

  response.body.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
end


# use hpricot to extract just the text we're looking for
def extract_text body, selector
  document = Hpricot(body)

  # replace a lot of common elements, outputs something like markdown
  document.search('h1').prepend("\n\n# ").append(" #\n")
  document.search('h2').prepend("\n\n## ").append(" ##\n")
  document.search('h3').prepend("\n\n### ").append(" ###\n")
  document.search('h4').prepend("\n\n#### ").append(" ####\n")
  document.search('h5').prepend("\n\n##### ").append(" #####\n")
  document.search('h6').prepend("\n\n###### ").append(" ######\n")
  document.search('p, li').append("\n")
  document.search('ul li').prepend("* ")
  document.search('ol li').prepend("1. ") # markdown doesn't care.
  document.search('br').each {|br| br.swap("\n")}
  document.search('ul, ol').prepend("\n").append("\n")
  document.search('a').each {|a| a.swap("[#{a.inner_text}](#{a.attributes['href']})") }

  content = document.search(selector).inner_text.strip
  if content.length < 100 # 100 characters is an abritrary value. Basically "small"
    puts "WARNING: Very Short Content (#{content.length} Bytes)".red
  end
  content
end


# write the new content to disk
def store name, what, where
  FileUtils.mkdir_p(File.dirname(where))
  File.open(where, 'wb') do |f|
    f << what
  end
  if `git status --porcelain "#{where}"`.strip.length > 0
    @changed_services << name
    puts "#{name} CHANGED"
  else
    puts "#{name} OK"
  end
end


# if anything has been changed, we want to store the current state of history.
def check_into_git
  if @changed_services.length > 0
    `git add #{CONFIG['history']}`
    `git commit -m "history changed for #{@changed_services.join(', ')}"`
    puts "=== changes ==="
    puts `git diff HEAD@{1}..HEAD`
  end
end


#
# Actual Program starts here
#

# go over the services and fetch their configured pages
configured_services.each do |page_config_file|
  page = JSON.load(File.open(page_config_file, 'r'))
  next unless page.has_key?('tosback2')

  page['tosback2'].each_pair do |key, value|
    next if value.class == String
    next unless value.has_key?('url')

    # preparinv variables
    uri = URI(value['url'])
    value['selector'] ||= "body"
    combined_name = "#{page['name']} - #{value['name']}"
    filename = File.join(CONFIG['history'], "#{combined_name}.md")

    # actual work
    body = retrieve_request_body(uri)
    content = extract_text(body, value['selector'])
    store(combined_name, content, filename)
    # store(combined_name, body, filename + '.html') # for debugging
  end
end

check_into_git()
