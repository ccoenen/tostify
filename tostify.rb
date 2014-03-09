# encoding: UTF-8
Encoding.default_external = Encoding::UTF_8 if RUBY_VERSION > '1.8.7'

require 'json'
require 'uri'
require 'open-uri'
require 'fileutils'
require 'chromatic'

CONFIG = JSON.load(File.open('config.json', 'r'))
HISTORY_DIR = File.join(File.dirname(__FILE__), CONFIG['history'])

CONFIG['pages'].each do |page|
  uri = URI(page['url'])
  page['name'] ||= uri.host
  puts "#{page['name'].red}: #{uri}"
  response = open(uri)

  FileUtils.mkdir_p(File.join(HISTORY_DIR, page['name']))
  File.open(File.join(HISTORY_DIR, page['name'], 'index.html'), 'wb') do |f|
    f << response.read
  end
end

puts `git status #{HISTORY_DIR}`
puts `git add #{HISTORY_DIR}`
puts `git commit -m "automatic history commit for #{Time.now}"`

