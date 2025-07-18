require 'optparse'
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

options = {
  chart: :group_by_week_electricity,
  sort: true
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: chart_config.rb [options]"
  opts.on("-n", "--name NAME", "Chart name") do |v|
    options[:chart] = v.to_sym
  end
  opts.on("-s", "--[no-]sort", "Sort chart configuration keys. Default is #{options[:sort]}") do |v|
    options[:sort] = v
  end
end

begin
  optparse.parse!
  mandatory = [:chart]
  missing = mandatory.select{ |param| options[param].nil? }
  unless missing.empty?
    raise OptionParser::MissingArgument.new(missing.join(', '))
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

definition = ChartManager::STANDARD_CHART_CONFIGURATION[options[:chart]]
if definition.nil?
  $stderr.puts "Chart #{options[:chart]} not found"
  exit
end

manager = ChartManager.new(nil)
chart_config = manager.resolve_chart_inheritance(definition)

ap chart_config, indent: -2, sort_keys: options[:sort]
