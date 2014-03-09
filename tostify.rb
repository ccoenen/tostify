# encoding: UTF-8
Encoding.default_external = Encoding::UTF_8 if RUBY_VERSION > '1.8.7'

require 'json'
require 'uri'
require 'net/http'
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
  http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == 'https'
    http.use_ssl = true
    http.ca_file = File.join(File.dirname(__FILE__), "cacert.pem")
  end
  response = http.get(uri.path)

  persistent_name = File.join(HISTORY_DIR, page['name'], page['persistent_name'])
  FileUtils.mkdir_p(File.dirname(persistent_name))
  File.open(persistent_name, 'wb') do |f|
    f << response.body
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
