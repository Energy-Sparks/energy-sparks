require 'require_all'
require_relative '../lib/dashboard.rb'
require_rel '../test_support'

class RunBenchmarks
  FRONTEND_CSS = '<link rel="stylesheet" media="all" href="C:\Users\phili\OneDrive\ESDev\energy-sparks_analytics\InputData\application-1.css" />
  <link rel="stylesheet" media="screen" href="\Users\phili\OneDrive\ESDev\energy-sparks_analytics\InputData\application-2.css" />'
  attr_reader :control
  def initialize(control, schools, source, cache_school)
    @control = control
    @source = source
    @school_pattern_match = schools
    @cache_school = cache_school
    @database = BenchmarkDatabase.new(control[:filename])
    @source_of_school_data = control[:source]
  end

  def run
    run_alerts_to_update_database if control.key?(:calculate_and_save_variables) && control[:calculate_and_save_variables]
    run_charts_and_tables(control[:run_charts_and_tables]) if control.key?(:run_charts_and_tables)
    run_content(control[:run_content]) if control.key?(:run_content)
  end

  def self.default_config
    RunAnalyticsTest.default_config.merge({ benchmarks: benchmark_default_config })
  end

  def self.benchmark_default_config
    {
      filename:       File.join(TestDirectory.instance.test_directory_name(test_type), 'benchmark database'),
      calculate_and_save_variables: true,
      asof_date:      Date.new(2022, 1, 20),
      # filter:         ->{ addp_area.include?('Sheffield') },
      # run_charts_and_tables: Date.new(2019,10,16),
      run_content:    {
        asof_date:      Date.new(2022, 1, 20),
        user:          { user_role: :admin }, # { user_role: :analytics, staff_role: nil }, # { user_role: :admin },
        filter:        nil, #->{ addp_area.include?('Bath') } # ->{ addp_area.include?('Sheffield') } # nil || addp_area.include?('Highland') },

      },
      # pages: [:change_in_gas_holiday_consumption_previous_holiday],
      compare_results: [
        :report_differences,
      ]
    }
  end

  private

  def self.test_type
    'Benchmarks'
  end

  # front end uses strings for keys, analytics symbols
  def transform_front_end_yaml_file(filenames)
    front_end_filename = filenames[:from_filename]
    analytics_filename = filenames[:to_filename] + '.yaml'
    front_end = YAML.load_file(front_end_filename + '.yaml')
    front_end.each do |date, schools|
      schools.each do |school_id, variables|
        schools[school_id] = variables.transform_keys { |key| key.to_sym }
      end
    end
    File.open(analytics_filename, 'w') { |f| f.write(YAML.dump(front_end)) }
  end

  def run_alerts_to_update_database
    school_list = SchoolFactory.instance.school_file_list(@source, @school_pattern_match)
    school_list.sort.each do |school_name|
      school = SchoolFactory.instance.load_school(@source, school_name, cache: @cache_school)
      calculate_alerts(school, control[:asof_date])
    end

    @database.save_database
  end

  def run_content(config)
    html = FRONTEND_CSS
    charts = []
    tables = []
    composite_tables = []

    content_manager = Benchmarking::BenchmarkContentManager.new(config[:asof_date])

    content_list = content_manager.available_pages(filter: config[:filter])

    content_list = content_list.select { |t, _c| @control[:pages].include?(t) } unless @control[:pages].nil? || @control[:pages].empty?

    content_list.each do |page_name, description|
      puts "Doing: #{page_name} : #{description}"

      dates = content_manager.benchmark_dates(page_name)

      db = @database.load_database(dates)

      content = content_manager.content(db, page_name, filter: config[:filter], user_type: config[:user])

      comparison = CompareContentResults.new(control, '', results_sub_directory_type: self.class.test_type)
      comparison.save_and_compare_content(page_name, content)

      page_html, page_charts, page_tables, page_table_composites = process_content(content)

      # print_content(page_html, page_charts, page_tables)

      html              += page_html
      charts            += page_charts
      tables            += page_tables
      composite_tables  += page_table_composites
    end

    save_html(html)
    save_charts_to_excel(charts.compact)
  end

  def print_content(html, charts, tables)
    banner('html')
    puts html

    banner('charts')
    ap charts[0]

    banner('tables')
    ap tables[0]
  end

  def banner(type)
    puts "\n"
    puts "===================================#{type}=================================="
    puts "\n"
  end

  def process_content(content)
    html = '<br>'
    charts = []
    tables = []
    tables_composite = []

    content.each do |content_item|
      case content_item[:type]
      when :analytics_html, :html, :table_html
        html += content_item[:content]
      when :title
        html += "<h2>#{content_item[:content]}</h2>"
      when :chart_name
        html += "<h2>Chart: #{content_item[:content]} inserted here</h2>"
      when :chart
        charts.push(content_item[:content])
      when :table_text
        tables.push(content_item[:content])
      when :table_composite
        tables_composite.push(content_item[:content])
      end
    end
    [html, charts, tables, tables_composite]
  end

  def run_charts_and_tables(asof_date)
    benchmarks = Benchmarking::BenchmarkManager.new(@database.database)

    ap benchmarks.structured_pages

    charts = []
    html = FRONTEND_CSS

    Benchmarking::BenchmarkManager::CHART_TABLE_CONFIG.each do |chart_table_name, definition|
      if definition[:type].include?(:table)
        table = benchmarks.run_benchmark_table(asof_date, chart_table_name, nil, nil, control[:filter], nil, control[:user])
        html += "<h2>#{definition[:name]}</h2>"
        html += html_table(definition, table)
      end

      if definition[:type].include?(:chart)
        chart = benchmarks.run_benchmark_chart(asof_date, chart_table_name, nil, nil, control[:filter], control[:user])
        charts.push(chart)
      end
    end

    save_html(html)
    save_charts_to_excel(charts)
  end

  def html_table(table_definition, rows)
    header = table_definition[:columns].map{ |column_definition| column_definition[:name] }
    formatted_rows = format_rows(rows, table_definition[:columns])
    HtmlTableFormatting.new(header, formatted_rows).html
  end

  def format_rows(rows, column_definitions)
    column_units = column_definitions.map{ |column_definition| column_definition[:units] }
    formatted_rows = rows.map do |row|
      row.each_with_index.map do |value, index|
        column_units[index] == String ? value : FormatUnit.format(column_units[index], value, :html, false, true, :ks2)
      end
    end
  end

  def save_html(html)
    html_writer = HtmlFileWriter.new('benchmark', results_sub_directory_type: self.class.test_type)
    html_writer.write(html)
    html_writer.close
  end

  def save_charts_to_excel(charts)
    worksheets = { 'Test' => charts }
    dir = TestDirectory.instance.results_directory('Benchmarks')
    excel_filename = File.join(dir, 'benchmark' + '.xlsx')
    excel = ExcelCharts.new(excel_filename)
    worksheets.each do |worksheet_name, charts|
      excel.add_charts(worksheet_name, charts.compact)
    end
    excel.close
  end

  # just put one chart per excel to pick up wrtie_xlsx chart corruption
  def save_charts_to_excel_debug(charts)
    charts.each do |chart|
      chart_name = chart[:config_name].to_s
      begin
        excel_filename = File.join(File.dirname(__FILE__), '../Results/benchmark ' + chart_name + '.xlsx')
        excel = ExcelCharts.new(excel_filename)
        excel.add_charts('Test', [chart])
        excel.close
      rescue Exception => e
        puts "Chart: #{chart_name} failed"
        puts e.message
        puts e.backtrace
        ap chart
        exit
      end
    end
  end

  def load_school_deprecated(school_name)
    school_factory.load_or_use_cached_meter_collection(:name, school_name, :analytics_db)
  end

  def load_school(school_name, source)
    school = nil
    begin
      school = school_factory.load_or_use_cached_meter_collection(:name, school_name, source)
    rescue Exception => e
      puts "=" * 100
      puts "Load of school #{school_name} failed"
      puts "=" * 100
      puts e.message
      puts e.backtrace
    end
    school
  end

  def school_factory
    $SCHOOL_FACTORY ||= SchoolFactory.new
  end

  def calculate_alerts(school, asof_date)
    AlertAnalysisBase.all_available_alerts.each do |alert_class|
      alert = alert_class.new(school)
      next if alert_class.benchmark_template_variables.empty?

      alert.benchmark_dates(asof_date).each do |benchmark_date|
        puts "Calculating alert for #{school.name} #{benchmark_date} #{alert_class}"
        next unless alert.valid_alert?

        alert.analyse(benchmark_date, true)
        puts "#{alert_class.name} failed" unless alert.calculation_worked
        next if !alert.make_available_to_users?

        save_benchmark_template_data(alert_class, alert, benchmark_date, school)
      end
    end
  end

  def save_benchmark_template_data(alert_class, alert, benchmark_date, school)
    new_data = alert.benchmark_template_data
    new_data.each do |key, value|
      @database.add_value(benchmark_date, school.urn, key, value)
    end
  end
end
