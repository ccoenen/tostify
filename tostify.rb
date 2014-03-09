# encoding: UTF-8
Encoding.default_external = Encoding::UTF_8 if RUBY_VERSION > '1.8.7'

require 'json'
require 'uri'
require 'open-uri'
require 'fileutils'
require 'chromatic'

CONFIG = JSON.load(File.open('config.json', 'r'))
HISTORY_DIR = File.join(File.dirname(__FILE__), CONFIG['history'])
changed_pages = []

CONFIG['pages'].each do |page|
  uri = URI(page['url'])
  # defaults for each page
  page['name'] ||= uri.host
  page['persistent_name'] ||= 'index.html'

  puts "#{page['name'].yellow}: #{uri}"
  response = open(uri)

  persistent_name = File.join(HISTORY_DIR, page['name'], page['persistent_name'])
  FileUtils.mkdir_p(File.dirname(persistent_name))
  File.open(persistent_name, 'wb') do |f|
    f << response.read
  end
  if (`git status --porcelain #{persistent_name}`.strip.length > 0)
    changed_pages << page['name']
	puts "  changed".red
  else
    puts "  unchanged".green
  end
end

`git add #{HISTORY_DIR}`
`git commit -m "history changed for #{changed_pages.join(', ')}"`
