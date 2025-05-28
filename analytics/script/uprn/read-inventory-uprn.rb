require_relative '../../lib/dashboard.rb'
require 'optparse'
require 'dotenv/load'
require_relative 'support.rb'

RETRY_INTERVAL = 3
MAX_RETRIES = 5

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: read-inventory-uprn.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on("-u", "--uprn UPRN", "Specify uprn") do |v|
    options[:uprn] = v
  end
end

puts

begin
  optparse.parse!
  mandatory = [:uprn]
  missing = mandatory.select{ |param| options[param].nil? }
  unless missing.empty?
    raise OptionParser::MissingArgument.new(missing.join(', '))
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

client = MeterReadingsFeeds::N3rgyDataApi.new(ENV['N3RGY_API_KEY'], ENV['N3RGY_DATA_URL'])

$stderr.puts "Reading inventory" if options[:verbose]

response = client.read_inventory(uprn: options[:uprn])

uri = response["uri"]
$stderr.puts "Fetching inventory from #{uri}" if options[:verbose]
inventory = client.fetch(uri, RETRY_INTERVAL, MAX_RETRIES)

puts JSON.pretty_generate(inventory) if options[:verbose]

i = Inventory.new(inventory)

if i.success?
  puts "Found #{i.devices.count} devices for this UPRN"
  i.device_summary.each do |device|
    puts CSV.generate_line([options[:uprn], device.id, device.type, device.commissioned, device.smets_version, device.smets_version])
  end
else
  puts "No devices found"
end
