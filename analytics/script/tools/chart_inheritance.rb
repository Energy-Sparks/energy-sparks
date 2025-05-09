require 'optparse'
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

#recursively find parents of a named chart
def inherits_from(chart_name, list)
  chart_config = ChartManager::STANDARD_CHART_CONFIGURATION[chart_name]
  if chart_config.key?(:inherits_from)
    list.push(chart_config[:inherits_from])
    inherits_from(chart_config[:inherits_from], list)
  end
end

#recursively find children of a named chart
def children_of(chart_name, list)
  immediate_children = ChartManager::STANDARD_CHART_CONFIGURATION.select do |_name, config|
    config.key?(:inherits_from) && config[:inherits_from] == chart_name
  end
  list.push(immediate_children.keys) unless immediate_children.empty?
  immediate_children.each_key do |child_chart_name|
    children_of(child_chart_name, list)
  end
end

options = {
  chart: :group_by_week_electricity,
  parents: false,
  children: true
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: chart_inheritance.rb [options]"
  opts.on("-p", "--parents", "Show parents. Default: #{options[:parents]}") do |v|
    options[:parents] = v
  end
  opts.on("-c", "--children", "Show children. Default: #{options[:children]}") do |v|
    options[:children] = v
  end
  opts.on("-n", "--name NAME", "Chart name") do |v|
    options[:chart] = v.to_sym
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

if ChartManager::STANDARD_CHART_CONFIGURATION[options[:chart]].nil?
  puts "Chart not found"
  exit
end

puts "Analysing chart: #{options[:chart]}"

if options[:parents]
  parents = []
  inherits_from(options[:chart], parents)
  puts "PARENTS. Ordered with direct parent first"
  ap parents
end

if options[:children]
  children = []
  children_of(options[:chart], children)
  puts "CHILDREN"
  ap children, {indent: 4}
end
