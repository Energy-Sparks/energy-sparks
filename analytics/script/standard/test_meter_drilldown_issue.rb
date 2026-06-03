require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/meter-drilldown ' + Time.now.strftime('%H %M') + '.log')
  @logger.level = :debug # :debug
end

def run_drilldowns(school, chart_name, column_drilldown_numbers, max_drilldowns)
  chart_manager = ChartManager.new(school)
  chart_data = chart_manager.run_standard_chart(chart_name)

  existing_chart_config = ChartManager::STANDARD_CHART_CONFIGURATION[chart_name]
  resolved_chart_config = chart_manager.resolve_chart_inheritance(existing_chart_config)
  ap resolved_chart_config

  charts = [chart_data]

  drilldowns = 0

  while chart_manager.drilldown_available?(existing_chart_config) && drilldowns < max_drilldowns do
    puts '-' * 80
    puts "Warning: nil chart data" if chart_data.nil?
    column = chart_data[:x_axis_ranges][column_drilldown_numbers[drilldowns]]
    new_chart_name, new_chart_config = chart_manager.drilldown(chart_name, existing_chart_config, nil, column)
    puts "Chart: #{chart_name}"
    ap new_chart_config
    chart_data = chart_manager.run_chart(new_chart_config, new_chart_name)
    charts.push(chart_data)
    existing_chart_config = new_chart_config
    puts '-' * 80
    drilldowns += 1
  end

  charts
end

school_name_pattern_match = ['bathampton*']
source_db = :unvalidated_meter_data
max_drilldowns = 4
column_drilldown_numbers = [10, 3, 2]
chart_name = :targeting_and_tracking_weekly_electricity_to_date_cumulative_line

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

school_names.each do |school_name|
  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

  puts '=' * 80
  puts "School: #{school_name}"
  puts "Chart: #{chart_name}"

  charts = run_drilldowns(school, chart_name, column_drilldown_numbers, max_drilldowns)

  filename = "Results\\meter-drilldown-test-charts #{school_name}.xlsx"

  puts "Saving results to #{filename}"

  excel = ExcelCharts.new(filename)

  excel.add_charts('Test', charts)

  excel.close
  puts '=' * 80
end
