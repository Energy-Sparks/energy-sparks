require_relative './logger_control.rb'
require_relative './monkey_patched_analytics_test_environment.rb'
# require_relative './test_directory_configuration.rb'
require 'ruby-prof'
$logger_format = 1

class RunTests
  include Logging

  def initialize(test_script)
    @test_script = test_script
    @log_filename = STDOUT
  end

  def run
    logger.info '=' * 120
    logger.info 'RUNNING TESTS:'
    logger.info '=' * 120

    @test_script.each do |component, configuration|
      case component
      when :dark_sky_temperatures
        update_dark_sky_temperatures
      when :grid_carbon_intensity
        update_grid_carbon_intensity
      when :sheffield_solar_pv
        update_sheffield_solar_pv
      when :schools
        @school_name_pattern_match = configuration
        @cache_school          = @test_script.fetch(:cache_school, true)
        @meter_readings_source = @test_script.fetch(:source, :unvalidated_meter_data)
      when :source
        @meter_readings_source = configuration
      when :meter_attribute_overrides
        @meter_attribute_overrides = configuration
      when :reports
        $logger_format = 2
        run_reports(configuration[:charts], configuration[:control])
      when :alerts
        run_alerts(configuration[:alerts], configuration[:control])
      when :charts
        run_charts(configuration[:charts], configuration[:control])
      when :economic_costs
        run_economic_costs(configuration[:charts], configuration[:control])
      when :drilldown
        run_drilldown(configuration)
      when :specific_drilldowns
        run_specific_drilldowns(configuration)
      when :generate_analytics_school_meta_data
        generate_analytics_school_meta_data
      when :timescales
        run_timescales(configuration)
      when :timescale_and_drilldown
        run_timescales_drilldown
      when :pupil_dashboard
        run_pupil_dashboard(configuration[:control])
      when :adult_dashboard
        run_adult_dashboard(configuration[:control])
      when :targeting_and_tracking
        run_targeting_and_tracking(configuration[:control])
      when :equivalences
        run_equivalences(configuration[:control])
      when :kpi_analysis
        run_kpi_calculations_deprecated(configuration)
      when :model_fitting
        run_model_fitting(configuration[:control])
      when :benchmarks
        run_benchmarks(configuration, @test_script[:schools], @test_script[:source], @test_script[:cache_school])
      else
        configure_log_file(configuration) if component.to_s.include?('logger')
      end
    end

    RecordTestTimes.instance.save_csv
  end

  private

  def load_school(school_name)
    override = @meter_attribute_overrides || {}
    SchoolFactory.instance.load_school(@meter_readings_source, school_name, meter_attributes_overrides: override, cache: @cache_school)
  end

  def schools_list
    SchoolFactory.instance.school_file_list(@meter_readings_source, @school_name_pattern_match)
  end

  def update_dark_sky_temperatures
    DownloadDarkSkyTemperatures.new.download
  end

  def update_grid_carbon_intensity
    DownloadUKGridCarbonIntensity.new.download
  end

  def update_sheffield_solar_pv
    DownloadSheffieldSolarPVData.new.download
  end

  def banner(title)
    '=' * 60 + title.ljust(60, '=')
  end

  def run_reports(chart_list, control)
    logger.info '=' * 120
    logger.info 'RUNNING REPORTS'
    failed_charts = []
    start_profiler
    schools_list.sort.each do |school_name|
      puts banner(school_name)
      @current_school_name = school_name
      reevaluate_log_filename
      school = load_school(school_name)
      next if school.nil?
      charts = RunCharts.new(school)
      charts.run(chart_list, control)
      failed_charts += charts.failed_charts
    end
    stop_profiler('reports')
    RunCharts.report_failed_charts(failed_charts, control[:report_failed_charts]) if control.key?(:report_failed_charts)
  end

  def run_drilldown(control)
    chart_name = control[:chart_name]

    schools_list.each do |school_name|
      excel_filename = File.join(TestDirectory.instance.results_directory('TimeScales'), school_name + '- drilldown.xlsx')
      school = load_school(school_name)
      chart_manager = ChartManager.new(school)
      chart_config = chart_manager.get_chart_config(chart_name)
      next unless chart_manager.drilldown_available?(chart_config)
      result = chart_manager.run_chart(chart_config, chart_name)
      fourth_column_in_chart = result[:x_axis_ranges][3]
      new_chart_name, new_chart_config = chart_manager.drilldown(chart_name, chart_config, nil, fourth_column_in_chart)
      new_chart_results = chart_manager.run_chart(new_chart_config, new_chart_name)
      excel = ExcelCharts.new(excel_filename)
      excel.add_charts('Test', [result, new_chart_results])
      excel.close
    end
  end

  def run_specific_drilldowns(control)
    excel_charts = {} # [worksheet_name] = [charts]
    schools_list.each do |school_name|
      excel_filename = File.join(TestDirectory.instance.results_directory('SpecificDrilldowns'), school_name + '- drilldown.xlsx')
      school = load_school(school_name)
      chart_manager = ChartManager.new(school)
      control.each do |test|
        test[:charts].each do |chart_setup|
          chart_setup.each do |excel_workheet_name, list_of_charts|
            excel_charts[excel_workheet_name] ||= []
            list_of_charts.each do |chart_name|
              chart_config = chart_manager.get_chart_config(chart_name)
              next unless chart_manager.drilldown_available?(chart_config)
              puts "Running standard chart #{chart_name}"
              result = chart_manager.run_chart(chart_config, chart_name)
              excel_charts[excel_workheet_name].push(result)

              test[:drilldown_columns].each do |drilldown_column_groups|
                drilldown_column_groups.each.with_index do |drilldown_column, depth|
                  next unless chart_manager.drilldown_available?(chart_config)

                  chart_column = result[:x_axis_ranges][drilldown_column]
                  puts "Drilling down onto standard chart #{chart_name} by column (#{drilldown_column}) #{chart_column.map(&:to_s)}"
                  chart_config[:name] += " (drilldown col #{drilldown_column})"
                  chart_name, chart_config = chart_manager.drilldown(chart_name, chart_config, nil, chart_column)

                  result = chart_manager.run_chart(chart_config, chart_name)

                  excel_charts[excel_workheet_name].push(result)
                end
              end
            end
          end
        end
      end

      excel = ExcelCharts.new(excel_filename)
      excel_charts.each do |worksheet_name, charts|
        excel.add_charts(worksheet_name.to_s, charts)
      end
      excel.close
    end
  end

  def run_timescales(control)
    chart_name = control[:chart_name]

    schools_list.each do |school_name|
      excel_filename = File.join(TestDirectory.instance.results_directory('TimeScales'), school_name + '- timescale shift.xlsx')
      school = load_school(school_name)
      chart_manager = ChartManager.new(school)
      chart_config = chart_manager.get_chart_config(chart_name)
      result = chart_manager.run_chart(chart_config, chart_name)

      chart_list = [result]

      new_chart_config = chart_config

      %i[move extend contract compare].each do |operation_type|
        manipulator = ChartManagerTimescaleManipulation.factory(operation_type, new_chart_config, school)
        next unless manipulator.chart_suitable_for_timescale_manipulation?
        puts "Display button: #{operation_type} forward 1 #{manipulator.timescale_description}" if manipulator.can_go_forward_in_time_one_period?
        puts "Display button: #{operation_type} back 1 #{manipulator.timescale_description}"    if manipulator.can_go_back_in_time_one_period?
        next unless manipulator.enough_data?(-1) # shouldn't be necessary if conform to above button display
        new_chart_config = manipulator.adjust_timescale(-1) # go back one period
        new_chart_results = chart_manager.run_chart(new_chart_config, chart_name)
        chart_list.push(new_chart_results)
      end

      excel = ExcelCharts.new(excel_filename)
      excel.add_charts('Test', chart_list)
      excel.close
    end
  end

  def run_adult_dashboard(control)
    run_specialised_dashboard(control, RunAdultDashboard)
  end

  def run_targeting_and_tracking(control)
    run_specialised_dashboard(control, RunTargetingAndTracking)
    filename = "#{control[:stats_csv_file_base]} #{Time.now.strftime('%d-%m-%Y %H-%M')}.csv"
    RunTargetingAndTracking.save_stats_to_csv(filename)
  end

  def run_specialised_dashboard(control, run_class)
    differences = {}
    failed_charts = []
    schools_list.sort.each do |school_name|
      school = load_school(school_name)
      puts "=" * 100
      puts "Running for #{school_name}"
      start_profiler
      test = run_class.new(school)
      differences[school_name] = test.run_flat_dashboard(control)
      stop_profiler('adult dashboard')
      failed_charts += test.failed_charts
    end
    run_class.summarise_differences(differences, control) if !control[:summarise_differences].nil? && control[:summarise_differences]
    RunCharts.report_failed_charts(failed_charts, control[:report_failed_charts]) if control.key?(:report_failed_charts)
  end

  def run_equivalences(control)
    schools_list.sort.each do |school_name|
      school = load_school(school_name)
      puts "=" * 100
      puts "Running for #{school_name}"
      test = RunEquivalences.new(school)
      test.run_equivalences(control)
    end
  end

  def run_pupil_dashboard(control)
    run_dashboard(control)
  end

  private def run_dashboard(control)
    schools_list.each do |school_name|
      school = load_school(school_name)
      test = PupilDashboardTests.new(school)
      test.run_tests(control)
    end
  end

  def run_timescales_drilldown
    schools_list.each do |school_name|
      chart_list = []
      excel_filename = File.join(TestDirectory.instance.results_directory('Timescales'), school_name + '- drilldown and timeshift.xlsx')
      school = load_school(school_name)

      puts 'Calculating standard chart'

      chart_manager = ChartManager.new(school)
      chart_name = :pupil_dashboard_group_by_week_electricity_kwh
      chart_config = chart_manager.get_chart_config(chart_name)
      result = chart_manager.run_chart(chart_config, chart_name)
      puts "Year: group by week chart:"
      ap chart_config
      puts "Chart parent time description (nil?): #{chart_manager.parent_chart_timescale_description(chart_config)}"

      chart_list.push(result)

      puts 'drilling down onto first column of chart => week chart by day'

      [0, 2].each do |drilldown_chart_column_number|
        column_in_chart = result[:x_axis_ranges][drilldown_chart_column_number]
        new_chart_name, new_chart_config = chart_manager.drilldown(chart_name, chart_config, nil, column_in_chart)
        puts 'Week chart: 7 x days'
        ap new_chart_config
        puts "Chart parent time description(year?): #{chart_manager.parent_chart_timescale_description(new_chart_config)}"
        new_chart_results = chart_manager.run_chart(new_chart_config, new_chart_name)
        chart_list.push(new_chart_results)

        puts 'Day chart: half hours'
        column_in_chart = result[:x_axis_ranges][drilldown_chart_column_number]
        new_chart_name, new_chart_config = chart_manager.drilldown(new_chart_name, new_chart_config, nil, column_in_chart)
        ap new_chart_config
        puts "Chart parent time description(week?): #{chart_manager.parent_chart_timescale_description(new_chart_config)}"
        new_chart_results = chart_manager.run_chart(new_chart_config, new_chart_name)
        chart_list.push(new_chart_results)

        if true
          %i[move extend contract compare].each do |operation_type|
            puts "#{operation_type} chart 1 week"

            manipulator = ChartManagerTimescaleManipulation.factory(operation_type, new_chart_config, school)
            next unless manipulator.chart_suitable_for_timescale_manipulation?
            puts "Display button: #{operation_type} forward 1 #{manipulator.timescale_description}" if manipulator.can_go_forward_in_time_one_period?
            puts "Display button: #{operation_type} back 1 #{manipulator.timescale_description}"    if manipulator.can_go_back_in_time_one_period?
            next unless manipulator.enough_data?(1) # shouldn't be necessary if conform to above button display
            new_chart_config = manipulator.adjust_timescale(1) # go forward one period
            new_new_chart_results = chart_manager.run_chart(new_chart_config, chart_name)
            chart_list.push(new_new_chart_results)
          end
        end
      end

      puts 'saving result to Excel'

      excel = ExcelCharts.new(excel_filename)
      excel.add_charts('Test', chart_list)
      excel.close
    end
  end

  private def chart_drilldown(chart_manager:, chart_name:, chart_config:, previous_chart_results:, chart_results:, drilldown_chart_column_number: 0)
    column_in_chart = previous_chart_results[:x_axis_ranges][chart_results.last]
    new_chart_name, new_chart_config = chart_manager.drilldown(chart_name, chart_config, nil, column_in_chart)
    puts "Chart parent time description(year?): #{chart_manager.parent_chart_timescale_description(new_chart_config)}"
    new_chart_results = chart_manager.run_chart(new_chart_config, new_chart_name)
    {
      chart_results:            new_chart_results,
      chart_name:               new_chart_name,
      parent_time_description:  chart_manager.parent_chart_timescale_description(new_chart_config)
  }
    chart_results.push(new_chart_results)
  end

  def run_kpi_calculations_deprecated(config)
    calculation_results = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
    schools_list.sort.each do |school_name|
      school = load_school(school_name)
      calculation = KPICalculation.new(school)
      calculation.run_kpi_calculations
      calculation_results = calculation_results.deep_merge(calculation.calculation_results)
      KPICalculation.save_kpi_calculation_to_csv(config, calculation_results)
    end
  end

  def run_benchmarks(control, schools, source, cache_school)
    benchmark = RunBenchmarks.new(control, schools, source, cache_school)
    benchmark.run
  end

  def run_model_fitting(control)
    logger.info '=' * 120
    logger.info 'RUNNING MODEL FITTING'
    failed_charts = []
    schools_list.sort.each do |school_name|
      puts banner(school_name)
      @current_school_name = school_name
      reevaluate_log_filename
      school = load_school(school_name)
      charts = RunModelFitting.new(school, results_sub_directory_type: 'Modelling')
      charts.run(control)
      failed_charts += charts.failed_charts
    end
  end

  def run_alerts(alert_list, control)
    logger.info '=' * 120
    logger.info 'RUNNING ALERTS'
    failed_alerts = []
    ENV['ENERGYSPARKSTESTMODE'] = 'ON'
    dates = RunAlerts.convert_asof_dates(control[:asof_date])

    schools_list.each do |school_name|
      @current_school_name = school_name
      dates.each do |asof_date|
        reevaluate_log_filename
        school = load_school(school_name)
        start_profiler
        alerts = RunAlerts.new(school)
        alerts.run(alert_list, control, asof_date)
        stop_profiler('alerts')
      end
      # failed_alerts += alerts.failed_charts
    end
    RecordTestTimes.instance.print_stats
    RecordTestTimes.instance.save_summary_stats_to_csv
    RunCharts.report_failed_charts(failed_charts, control[:report_failed_charts]) if control.key?(:report_failed_charts)
  end

  def run_economic_costs(charts, control)
    run_charts(charts, control, dir_name: 'EconomicCosts')
  end

  def run_charts(charts, control, dir_name: 'Charts')
    logger.info '=' * 120
    logger.info 'RUNNING CHARTS'
    failed_charts = []
    ENV['ENERGYSPARKSTESTMODE'] = 'ON'

    schools_list.each do |school_name|
      puts banner(school_name)
      @current_school_name = school_name
      reevaluate_log_filename
      school = load_school(school_name)
      start_profiler
      charts_runner = RunCharts.new(school, results_sub_directory_type: dir_name)
      charts_runner.run_structured_chart_list(charts, control)
      stop_profiler('charts')
      failed_charts += charts_runner.failed_charts
    end
    RecordTestTimes.instance.print_stats
    RecordTestTimes.instance.save_summary_stats_to_csv
    RunCharts.report_failed_charts(failed_charts, control[:report_failed_charts]) if control.key?(:report_failed_charts)
  end

  private def start_profiler
    RubyProf.start if @test_script[:ruby_profiler] == true
  end

  private def stop_profiler(name)
    if @test_script[:ruby_profiler] == true
      prof_result = RubyProf.stop
      printer = RubyProf::GraphHtmlPrinter.new(prof_result)
      printer.print(File.open('log\code-profile - ' + name + Date.today.to_s + '.html','w'))
    end
  end

  def configure_log_file(configuration)
    @log_filename = configuration[:name]
    reevaluate_log_filename
  end

  def reevaluate_log_filename
    puts "Got here reevaluate_log_filename"
    return

    filename = @log_filename.is_a?(IO) ? @log_filename : (@log_filename % { school_name: @current_school_name, time: Time.now.strftime('%d %b %H %M') })
    if !@@es_logger_file.nil? &&
      @@es_logger_file.file.is_a?(IO) &&
      @@es_logger_file.file != STDOUT &&
      @@es_logger_file.file != filename &&
      @@es_logger_file.file.close
    end

    @@es_logger_file.file = filename
  end
end
