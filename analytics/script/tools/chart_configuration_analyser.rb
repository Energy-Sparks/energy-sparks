require 'optparse'
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

# Runs through chart configuration.rb, resolving all chart inheritance
# then produces a summary of the chart configuration keys used

manager = ChartManager.new(nil)

#resolve inheritance for all charts
configs = ChartManager::STANDARD_CHART_CONFIGURATION.map do |chart_name, definition|
  [chart_name, manager.resolve_chart_inheritance(definition)]
end.to_h

#accumulate occurences of each chart config key
stats = Hash.new{ |hash, key| hash[key] = Array.new }

configs.each do |_name, definition|
  definition.each do |key, value|
    stats[key].push(value)
  end
end

#count up occurences of each key
counted_stats = stats.map do |key, value|
  [key, value.each_with_object(Hash.new(0)) { |l, o| o[l] += 1 }]
end.to_h

#Dump keys, in alphabetical order with values sorted by occurences
counted_stats.keys.sort.each do |k|
  ap k
  counted_stats[k].sort_by {|k,v| -v }.each do |k,v|
    ap [v, k], multiline: false
  end
  puts
end
