require_relative '../../lib/dashboard.rb'
require 'optparse'
require 'dotenv/load'
require_relative 'support.rb'

RETRY_INTERVAL = 8
MAX_RETRIES = 10

def log(msg, verbose)
  $stderr.puts(msg) if verbose
end

def extract_fields(school, fields, named_fields)
  extracted = fields.dup
  extracted.map do |field|
    named_fields ? school[field] : school[field.to_i]
  end
end

def extracted_field_names(fields, named_fields)
  named_fields ? fields : fields.map {|f| "Field_#{f}"}
end

options = {
  headers: true,
  report: "scan-inventory.csv",
  interval: RETRY_INTERVAL,
  retries: MAX_RETRIES
}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: scan-inventories.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on("-f", "--file FILE", "CSV file to parse") do |v|
    options[:file] = v
  end
  opts.on("-n", "--no-header", "Indicate CSV has no header. UPRNs must be in first column") do |v|
    options[:headers] = false
  end
  opts.on("-o", "--output REPORT", "Name of file to generate. Default: #{options[:report]}") do |v|
    options[:report] = v
  end
  opts.on("-r", "--retries RETRIES", Integer, "Maximum number of retries to fetch inventory. Default: #{options[:retries]}") do |v|
    options[:retries] = v
  end
  opts.on("-i", "--interval INTERVAL", Integer, "Retry interval in seconds. Default: #{options[:interval]}") do |v|
    options[:interval] = v
  end
  opts.on("-e", "--extract FIELDS", "Fields to extract from input CSV and add to output. Comma-separated list of field names or indexes") do |v|
    options[:extract] = v.split(",").freeze
  end
  opts.on("-h", "--help", "Print options") do |v|
    puts optparse
    exit
  end
end

puts

begin
  optparse.parse!
  mandatory = [:file]
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

log("Processing #{options[:file]}", true)

client = MeterReadingsFeeds::N3rgyDataApi.new(ENV['N3RGY_API_KEY'], ENV['N3RGY_DATA_URL'])

all_devices = {}
schools = 0
errors = 0
CSV.foreach(options[:file], headers: options[:headers]) do |school|
  schools += 1
  if options[:headers]
    uprn = school["UPRN"]
  else
    uprn = school[0]
  end
  next unless uprn
  begin
    log("Reading inventory for #{uprn}", true)
    response = client.read_inventory(uprn: uprn)

    uri = response["uri"]
    log("Fetching inventory from #{uri}. Retries: #{options[:retries]}. Interval: #{options[:interval]}", options[:verbose])


    inventory = client.fetch(uri, options[:interval], options[:retries])
    i = Inventory.new(inventory)
    if i.success?
      log("Found #{i.devices.count} devices for this UPRN", options[:verbose])
      all_devices[uprn] = {
        fields: extract_fields(school, options[:extract], options[:headers]),
        devices: i.device_summary
      }
    else
      log("No devices found", options[:verbose])
    end
  rescue => e
    errors += 1
    log("Error processing #{uprn}", true)
    log(e.message, true)
    log(e.backtrace, options[:verbose])
  end
end

log("Writing output to #{options[:report]}", options[:verbose])
count = 0

DEVICE_FIELDS = ["ID", "TYPE", "COMMISSIONED", "SMETS_CHTS_VERSION", "GBCS_VERSION"]
CSV.open(options[:report], "w") do |csv|
  if options[:extract]
    csv << ["UPRN"] + extracted_field_names(options[:extract],options[:headers]) + DEVICE_FIELDS
  else
    csv << ["UPRN"] + DEVICE_FIELDS
  end

  all_devices.each do |uprn, result|
    count += result[:devices].length
    result[:devices].each do |device|
      if options[:extract]
        csv << [uprn] + result[:fields] + [device.id, device.type, device.commissioned, device.smets_version, device.gbcs_version]
      else
        csv << [uprn, device.id, device.type, device.commissioned, device.smets_version, device.gbcs_version]
      end
    end
  end
end

puts "Searched #{schools} schools. Found a total of #{count} devices for #{all_devices.keys.count} schools. (#{errors} errors)"
