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
@changed_services = []


#
# High level functions start here
#


# retrieves the utf-8 encoded request body for url
def retrieve_request_body url, redirect_limit = 5
  raise "Too many redirects" if redirect_limit < 1
  uri = URI(url)

  http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == 'https'
    http.use_ssl = true
    http.ca_file = "cacert.pem"
  end

  response = http.get(uri.path)
  puts "#{uri} (HTTP #{response.code}, #{response.body.length} Bytes)".yellow

  if response.code == "200"
    if response["Content-Type"] =~ /charset=(.*)$/
      response.body.force_encoding($1)
    else
      response.body.force_encoding('UTF-8')
    end
    response.body.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
  elsif response.code == "301" || response.code == "302"
    # follow redirect
    location = response['Location']
    if location =~ /\A\//
      puts "  Fixing invalid relative redirect to #{location}, received from #{uri}" if $DEBUG
      uri.path = location
      location = uri.to_s
    end

    retrieve_request_body(URI(location), redirect_limit-1)
  else
    raise "Response code was #{response.code}"
  end
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
    raise "Very Short Content (#{content.length} Bytes)"
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
    puts "  #{name} CHANGED"
  else
    puts "  #{name} OK"
  end
end



def download(url, selector, name)
  filename = File.join(CONFIG['history'], "#{name}.md")

  # actual work
  begin
    body = retrieve_request_body(url)
    content = extract_text(body, selector)
    store(name, content, filename)
    store(name, body, filename + '.html') if $DEBUG
  rescue StandardError => e
    puts "  ERROR while processing #{name}".red
    puts "  #{e.inspect}".red
    raise e
  end
end


# if anything has been changed, we want to store the current state of history.
def check_into_git
  if @changed_services.length > 0
    `git add #{CONFIG['history']}`
    `git commit -m "history changed for #{@changed_services.join(', ')}"`
    puts "\n\n\n=== changes ==="
    puts `git diff HEAD@{1}..HEAD`
  end
end


#
# Actual Program starts here
#

# go over the tosback2-style configuration files and fetch their configured pages
tosback_services = Dir[File.join(CONFIG['services'], '*.json')]
tosback_services.each do |page_config_file|
  puts "\n==> #{page_config_file} <==" if $DEBUG
  page = JSON.load(File.open(page_config_file, 'r'))
  unless page.has_key?('tosback2')
    puts "  WARNING: No 'tosback2' key found in #{page_config_file}".red if $DEBUG
    next
  end

  page['tosback2'].each_pair do |key, value|
    next if value.class == String
    unless value.has_key?('url')
      puts "  WARNING: No 'url' key found in #{page_config_file} / tosback2 / #{key}".red if $DEBUG
      next
    end

    # preparing variables
    value['selector'] ||= "body"
    combined_name = "#{page['name']} - #{value['name']}"

    download(value['url'], value['selector'], combined_name)
  end
end

check_into_git()
