require 'uri'
require 'open-uri'
require 'fileutils'
require 'chromatic'

HISTORY_DIR = File.join(File.dirname(__FILE__), 'history')

CONFIG = [
  {
    "url" => "http://www.google.de/intl/de/policies/terms/regional.html"
  }
]

CONFIG.each do |config|
  uri = URI(config['url'])
  config['name'] ||= uri.host
  puts "#{config['name'].red}: #{uri}"
  response = open(uri)

  FileUtils.mkdir_p(File.join(HISTORY_DIR, config['name']))
  File.open(File.join(HISTORY_DIR, config['name'], 'index.html'), 'wb') do |f|
    f << response.read
  end
end

puts `git status #{HISTORY_DIR}`
puts `git add #{HISTORY_DIR}`
puts `git commit -m "automatic history commit for #{Time.now}"`

