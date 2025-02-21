# runs charts and advice and outputs html and Excel files
class RunAnalyticsTest
  include Logging

  attr_reader :failed_charts

  def self.default_config
    {
      logger1:        { name: TestDirectory.instance.log_directory + "/datafeeds %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
      ruby_profiler:  false,
      schools:        ['*'],
      source:         :unvalidated_meter_data,
      logger2:        { name: TestDirectory.instance.log_directory + "/pupil dashboard %{school_name} %{time}.log", format: "%{datetime} %{severity.ljust(5, ' ')}: %{msg}\n" },
    }
  end

  def initialize(school, results_sub_directory_type:)
    @school = school
    @worksheets = Hash.new { |worksheet_name, charts| worksheet_name[charts] = [] }
    @runtime = Time.now.strftime('%d/%m/%Y %H:%M:%S')
    @failed_charts = []
    @results_sub_directory_type = results_sub_directory_type
  end

  def class_names_to_excel_tab_names(classes)
    class_name_map = classes.map { |c| [c, (c.name.scan /\p{Upper}/).join.downcase] }.to_h
    groups = class_name_map.then { |h| h.keys.group_by { |k| h[k] } }.to_h

    unique_list = {}

    groups.each do |excel_tab_name, class_names|
      if class_names.length == 1
        unique_list[class_names.first] = excel_tab_name
      else
        class_names.each.with_index do |cn, i|
          unique_list[class_names.first] = "#{excel_tab_name}#{i}"
        end
      end
    end

    unique_list
  end

  def compare_results(control, object_name, results, asof_date)
    results.each do |type, content|
      comparison = CompareContent2.new(@school.name, control, results_sub_directory_type: @results_sub_directory_type)
      name = "#{asof_date.strftime('%Y%m%d')} #{object_name} #{type}"
      comparison.save_and_compare(name, content)
    end
  end

  def print_banner(title, lines_before_after = 0)
    lines_before_after.times { puts banner }
    puts banner(title)
    lines_before_after.times { puts banner }
  end

  def banner(title= '')
    len_before = ((150 - title.length) / 2).floor
    len_after = 150 - title.length - len_before
    '=' * len_before + title + '=' * len_after
  end

  def self.convert_asof_dates(date_spec)
    if date_spec.is_a?(Date)
      [date_spec]
    elsif date_spec.is_a?(Range)
      date_spec.to_a
    elsif date_spec.is_a?(Array)
      date_spec
    end
  end

  def run(charts, control)
    charts = [charts].flatten
    charts.each do |config_component|
      run_config_component(config_component)
    end
    save_to_excel
    write_html
    report_calculation_time(control)
    CompareChartResults.new(control[:compare_results], @school.name, directory_name: @results_sub_directory_type).compare_results(all_charts)
    log_all_results
  end

  def self.report_failed_charts(failed_charts, detail)
    failed_charts.each do |failed_chart|
      short_backtrace = failed_chart.key?(:backtrace) && !failed_chart[:backtrace].nil? ? failed_chart[:backtrace][0].split('/').last : 'no backtrace'
      tolerate_failure = failed_chart.fetch(:tolerate_failure, false) ? 'ok   ' : 'notok'
      puts sprintf('%-15.15s %s %-85.85s %-35.35s %-80.80s %-20.20s',
        failed_chart[:school_name], tolerate_failure, failed_chart[:chart_name], failed_chart[:message], short_backtrace,
        shorten_type(failed_chart[:type]))
      puts failed_chart[:backtrace] if detail == :detailed
    end
  end

  def run_structured_chart_list(structured_list, control)
    structured_list.each do |excel_tab_name, chart_list|
      chart_list.each do |chart_name|
        run_chart(excel_tab_name.to_s, chart_name, provide_advice: false) if ChartManager.new(@school).standard_chart_valid?(chart_name)
      end
    end
    save_to_excel if control[:save_to_excel] == true
    report_calculation_time(control)
    CompareChartResults.new(control[:compare_results], @school.name, directory_name: @results_sub_directory_type).compare_results(all_charts)
    log_all_results
  end

  def self.standard_charts_for_school
    [
      management_dashboard_charts,
      public_dashboard_charts_for_school,
      other_charts,
      targeting_and_tracking_charts,
      pupil_dashboard_charts
    ].inject(:merge)
  end

  private

  def self.management_dashboard_charts
    {
      'ManDash' => %i[
        management_dashboard_group_by_week_electricity
        management_dashboard_group_by_week_gas
        management_dashboard_group_by_week_storage_heater
      ]
    }
  end

  def self.other_charts
    {
      'Other' => %i[
        electricity_cost_comparison_last_2_years_accounting
      ]
    }
  end

  def self.targeting_and_tracking_charts
    {
      'Target' => %i[
        targeting_and_tracking_weekly_electricity_to_date_cumulative_line
        targeting_and_tracking_weekly_gas_to_date_cumulative_line
        targeting_and_tracking_weekly_storage_heater_to_date_cumulative_line
        targeting_and_tracking_weekly_electricity_to_date_line
        targeting_and_tracking_weekly_gas_to_date_line
        targeting_and_tracking_weekly_storage_heater_to_date_line
        targeting_and_tracking_weekly_electricity_one_year_line
        targeting_and_tracking_weekly_gas_one_year_line
        targeting_and_tracking_weekly_storage_heater_one_year_line
      ]
    }
  end

  def self.pupil_dashboard_charts
    pages = []
    page_config = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[:pupil_analysis_page]
    RunAnalyticsTest.charts_on_pages_recursive(page_config, pages)
    {
      'Pupils' => pages.flatten.uniq
    }
  end

  def self.public_dashboard_charts_for_school
    page_charts = {}

    DashboardConfiguration::ADULT_DASHBOARD_GROUPS.each do |group, pages|
      pages.each do |page_name|
        config = DashboardConfiguration::ADULT_DASHBOARD_GROUP_CONFIGURATIONS[page_name]
        next if config.nil?

        page_charts[config[:excel_worksheet_name]] = config[:charts]
      end
    end

    page_charts
  end

  private_class_method def self.shorten_type(type)
    return type if type == "" || type.nil?
    type.to_s.gsub('EnergySparks', 'ES').gsub('Exception', 'EX')
  end

  def excel_variation
    '- charts test'
  end

  def excel_filename
    File.join(TestDirectory.instance.results_directory(@results_sub_directory_type), @school.name + excel_variation + '.xlsx')
  end

  def report_calculation_time(control)
    puts "Average calculation rate #{average_calculation_rate.round(1)} charts per second" if control.key?(:display_average_calculation_rate)
  end

  def log_all_results
    failed = @failed_charts.nil? ? -1 : @failed_charts.length
    charts = number_of_charts.nil? ? 0 : number_of_charts
    calc_time = total_chart_calculation_time.nil? ? 0.0 : total_chart_calculation_time
    puts sprintf('Completed %2d charts for %-25.25s %d failed in %.3fs', charts, @school.name, failed, calc_time)
  end

  def number_of_charts
    @worksheets.map { |worksheet, charts| charts.length}.sum
  end

  def total_chart_calculation_time
    @worksheets.map { |worksheet, charts| charts.map { |chart| chart[:calculation_time] }.sum }.sum
  end

  def run_config_component(config_component)
    if config_component.is_a?(Symbol) && config_component == :dashboard
      #run_dashboard
    elsif config_component.is_a?(Hash) && config_component.keys[0] == :adhoc_worksheet
      run_single_dashboard_page(config_component.values[0])
    elsif config_component.is_a?(Hash) && config_component.keys[0] == :pupils_dashboard
      run_recursive_dashboard_page(config_component.values[0])
    elsif config_component.is_a?(Hash) && config_component.keys[0] == :adults_dashboard
      run_flat_dashboard
    end
  end

  def run_recursive_dashboard_page(parent_page_config)
    puts 'run_recursive_dashboard_page'
    pages = []
    config = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[parent_page_config]
    flatten_recursive_page_hierarchy(config, pages)
    pages.each do |page|
      page.each do |page_name, charts|
        charts.each do |chart_name|
          run_chart(page_name, chart_name)
        end
      end
    end
  end

  def flatten_recursive_page_hierarchy(parent_page,  pages, name = '')
    if parent_page.is_a?(Hash)
      if parent_page.key?(:sub_pages)
        parent_page[:sub_pages].each do |sub_page|
          new_name = name + sub_page[:name] if sub_page.is_a?(Hash) && sub_page.key?(:name)
          flatten_recursive_page_hierarchy(sub_page,  pages, new_name)
        end
      else
        pages.push({ name => parent_page[:charts] })
      end
    else
      puts 'Error in recursive dashboard definition 1'
    end
  end

  def self.charts_on_pages_recursive(page,  pages)
    if page.is_a?(Hash)
      pages.push([page[:charts]].flatten.compact)
      if page.key?(:sub_pages)
        page[:sub_pages].each do |sub_page|
          charts_on_pages_recursive(sub_page,  pages)
        end
      end
    end
  end

  def run_single_dashboard_page(single_page_config)
    logger.info "    Doing page #{single_page_config[:name]}"
    logger.info "        Charts #{single_page_config[:charts].join(';')}"
    single_page_config[:charts].each do |chart_name|
      run_chart(single_page_config[:name], chart_name)
    end
  end

  public def run_chart(page_name, chart_name, override: nil, provide_advice: true)
    logger.info "            #{chart_name}"

    chart_manager = ChartManager.new(@school)

    unless chart_manager.approx_valid_chart?(chart_name)
      puts "Skipping chart #{chart_name}"
      return nil
    end

    puts "Running  chart: #{chart_name}"

    chart_results = nil
    begin
      chart_results = chart_manager.run_chart_group(chart_name, override, true, provide_advice: provide_advice) # chart_override)
      if chart_results.nil?
        puts "Nil chart result for #{chart_name}"
        @failed_charts.push( { school_name: @school.name, chart_name: chart_name, message: 'Unknown', backtrace: nil } )
      else
        chart_results = [chart_results] unless chart_results.is_a?(Array)
        @worksheets[page_name] += chart_results.flatten # could be a composite chart
      end
    rescue EnergySparksNotEnoughDataException => e
      puts 'Chart failed: not enough data'
      puts e.backtrace
      @failed_charts.push( { school_name: @school.name, chart_name: chart_name,  message: e.message, backtrace: e.backtrace, type: e.class.name } )
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      @failed_charts.push( { school_name: @school.name, chart_name: chart_name,  message: e.message, backtrace: e.backtrace, type: e.class.name } )
      nil
    end
    chart_results
  end

  def save_to_excel
    excel = ExcelCharts.new(excel_filename)
    @worksheets.each do |worksheet_name, charts|
      excel.add_charts(worksheet_name, charts.compact)
    end
    excel.close
  end

  def average_calculation_time
    all_times = @worksheets.values.map { |charts| charts.map { |chart| chart[:calculation_time] } }.flatten
    return Float::NAN if all_times.empty?
    all_times.sum / all_times.length
  end

  def average_calculation_rate
    1.0 / average_calculation_time
  end

  def all_charts
    @worksheets.values.flatten
  end

  def write_html(filename_suffix = '')
    html_file = HtmlFileWriter.new(@school.name + filename_suffix, results_sub_directory_type: @results_sub_directory_type)
    @worksheets.each do |worksheet_name, charts|
      html_file.write_header(worksheet_name)
      charts.compact.each do |chart|
        html_file.write_header_footer(chart[:config_name], chart[:advice_header], chart[:advice_footer])
      end
    end
    html_file.close
  end
end

class RunCharts < RunAnalyticsTest
end
