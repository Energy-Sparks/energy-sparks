# test report manager
require 'require_all'
require_relative '../lib/dashboard.rb'
require_rel '../test_support'
require 'hashdiff'

class ReportConfigSupport
  include Logging
  attr_reader :schools, :chart_manager, :school
  attr_accessor :worksheet_charts, :excel_name

  def initialize

    # @dashboard_page_groups = now in lib/dashboard/charting_and_reports/dashboard_configuration.rb
    # @school_report_groups = { # 2 main dashboards: 1 for electric only schools, one for electric and gas schools

    @schools = {
    # Bath
      'Bishop Sutton Primary School'            => :electric_and_gas,
      'Castle Primary School'                   => :electric_and_gas,
      'Freshford C of E Primary'                => :electric_and_gas,
      'Marksbury C of E Primary School'         => :electric_and_storage_heaters,
      'Paulton Junior School'                   => :electric_and_gas_and_solar_pv,
      'Pensford Primary'                        => :electric_only,
      'Roundhill School'                        => :electric_and_gas,
      'Saltford C of E Primary School'          => :electric_and_gas,
      'St Johns Primary'                        => :electric_and_gas,
      'St Marks Secondary'                      => :electric_and_gas,
      'St Martins Garden Primary School'        => :electric_and_gas,
      'St Michaels Junior Church School'        => :electric_and_gas,
      'St Saviours Junior'                      => :electric_and_gas,
      'Stanton Drew Primary School'             => :electric_and_storage_heaters,
      'Twerton Infant School'                   => :electric_and_gas,
      'Westfield Primary'                       => :electric_and_gas,
    # Sheffield
      'Abbey Lane'                              => :electric_and_gas,
      'Athelstan Primary School'                => :electric_and_gas,
      'Ballifield Community Primary School'     => :electric_and_gas,
      'Bankwood Primary School'                 => :electric_and_gas,
      'Brunswick'                               => :electric_and_gas,
      'Coit Primary School'                     => :gas_only,
      'Ecclesall Primary School'                => :electric_and_gas,
      'Ecclesfield Primary School'              => :electric_and_gas,
      'King Edward VII Upper School'            => :electric_and_gas,
      'Mossbrook'                               => :electric_and_gas,
      'Mundella'                                => :electric_and_gas,
      'St Thomas of Canterbury'                 => :electric_and_gas,
      'Walkley Tennyson School'                 => :electric_and_gas,
      'Watercliffe Meadow Primary'              => :electric_and_gas,
      'Whiteways Primary'                       => :electric_and_gas,
      'Woodthorpe Primary School'               => :electric_and_gas,
      'Wybourn Primary School'                  => :electric_only,
    # Frome
      'Christchurch First School'               => :gas_only,
      'Critchill School'                        => :electric_and_gas,
      'Frome College'                           => :electric_only,
      'Hugh Sexey'                              => :electric_and_solar_pv,
      'Oakfield Academy'                        => :electric_and_gas,
      'St Louis First School'                   => :electric_and_gas,
      'Trinity First School'                    => :electric_and_gas,
    }
    @benchmarks = []

    # ENV['School Dashboard Advice'] = 'Include Header and Body'
    $SCHOOL_FACTORY = SchoolFactory.new

    @chart_manager = nil
    @school_metadata = nil
    @worksheet_charts = {}
    @failed_reports = []
    @differing_results = []

    logger.debug "\n" * 8
  end

  def self.suppress_output(school_name)
    begin
      original_stdout = $stdout.clone
      $stdout.reopen(File.new(File.join(TestDirectory.instance.log_directory, school_name + 'loading log.txt', 'w')))
      retval = yield
    rescue StandardError => e
      $stdout.reopen(original_stdout)
      raise e
    ensure
      $stdout.reopen(original_stdout)
    end
    retval
  end

  def report_failed_charts
    puts '=' * 100
    puts 'Failed charts'
    @failed_reports.each do |school_name, chart_name|
      puts sprintf('%-25.25s %-45.45s', school_name, chart_name)
    end
    puts '-' * 100
    puts 'Differing charts'
    @differing_results.each do |difference|
      puts difference
    end
    puts '_' * 120
  end

  def self.banner(title)
    cols = 120
    len_before = ((cols - title.length) / 2).floor
    len_after = cols - title.length - len_before
    '=' * len_before + title + '=' * len_after
  end

  def setup_school(school, school_name)
    @school_name = school_name
    @school = school
    @chart_manager = ChartManager.new(@school)
  end

  def load_school(school_name, suppress_debug = false)
    logger.debug self.class.banner("School: #{school_name}")

    puts self.class.banner("School: #{school_name}")

    @excel_name = school_name

    @school_name = school_name

    @school = $SCHOOL_FACTORY.load_or_use_cached_meter_collection(:name, school_name, :analytics_db)

    @chart_manager = ChartManager.new(@school)

    @school # needed to run simulator
  end

  def report_benchmarks
    @benchmarks.each do |bm|
      puts bm
    end
    @benchmarks = []
  end

  def save_excel_and_html
    write_excel
    write_html
    # @worksheet_charts = {}
  end

  def do_one_page(page_config_name, reset_worksheets = true, chart_override = nil, name_override = nil)
    @worksheet_charts = {} if reset_worksheets
    page_config = DashboardConfiguration::DASHBOARD_PAGE_GROUPS[page_config_name]
    worksheet_tab_name = name_override.nil? ? page_config[:name] : name_override.to_s
    do_one_page_internal(worksheet_tab_name, page_config[:charts], chart_override)
  end

  def do_chart_list(page_name, list_of_charts, empty_existing_chart_list = true, chart_override = nil)
    @worksheet_charts = {} if empty_existing_chart_list
    do_one_page_internal(page_name, list_of_charts, chart_override)
  end

  def write_excel(filename = File.join(File.dirname(__FILE__), '../Results/') + @excel_name + '- charts test.xlsx')
    @html_chart_list = @worksheet_charts
    @worksheet_charts
    excel = ExcelCharts.new(filename)
    @worksheet_charts.each do |worksheet_name, charts|
      excel.add_charts(worksheet_name, charts)
    end
    excel.close
    @worksheet_charts = {}
  end

  def write_html
    html_file = HtmlFileWriter.new(@school_name)
    @html_chart_list.each do |worksheet_name, charts|
      html_file.write_header(worksheet_name)
      charts.each do |chart|
        html_file.write_header_footer(chart[:config_name], chart[:advice_header], chart[:advice_footer])
      end
    end
    html_file.close
    @html_chart_list = {}
  end

  def do_one_page_internal(page_name, list_of_charts, chart_override = nil)
    logger.debug self.class.banner("Running report page  #{page_name}")
    @worksheet_charts[page_name] = []
    list_of_charts.each do |chart_name|
      charts = do_charts_internal(chart_name, chart_override)
      save_and_compare_chart_data(chart_name, charts) if defined?(@@energysparksanalyticsautotest)
      unless charts.nil?
        charts.each do |chart|
          ap(chart, limit: 20, color: { float: :red }) if ENV['AWESOMEPRINT'] == 'on'
          @worksheet_charts[page_name].push(chart) unless chart.nil?
        end
      end
    end
  end

  def save_and_compare_chart_data(chart_name, charts)
    if chart_name.is_a?(Hash)
      puts 'Unable to save and compare composite chart'
      return
    end
    save_chart(@@energysparksanalyticsautotest[:new_data], chart_name, charts)
    previous_chart = load_chart(@@energysparksanalyticsautotest[:original_data], chart_name)
    if previous_chart.nil?
      puts "Chart comparison: for #{@school_name}:#{chart_name} is missing from benchmark chart list"
      return
    end
    compare_charts(chart_name, previous_chart, charts)
  end

  def compare_charts(chart_name, old_data, new_data)
    diff = old_data == new_data
    puts "Chart result comparison #{chart_name[0..20]}"
    unless diff # HashDiff is horribly slow, so only run if necessary
      puts "+" * 120
      puts "Chart #{chart_name} differs"
      h_diff = Hashdiff.diff(old_data, new_data, use_lcs: false, :numeric_tolerance => 0.000001) # use_lcs is O(N) otherwise and takes hours!!!!!
      if @@energysparksanalyticsautotest[:skip_advice] && h_diff.to_s.include?('html')
        puts 'Advice differs'
      else
        if h_diff.to_s.length > 2000
          puts "Lots of differences #{h_diff.to_s.length} length"
        else
          ap(h_diff)
        end
      end
      @differing_results.push(sprintf('%30.30s %20.20s %s', @school_name, chart_name, h_diff))
      puts "+" * 120
    end
  end

  def load_chart(path, chart_name)
    yaml_filename = yml_filepath(path, chart_name)
    return nil unless File.file?(yaml_filename)
    meter_readings = YAML::load_file(yaml_filename)
  end

  def save_chart(path, chart_name, data)
    yaml_filename = yml_filepath(path, chart_name)
    File.open(yaml_filename, 'w') { |f| f.write(YAML.dump(data)) }
  end

  def yml_filepath(path, chart_name)
    full_path ||= File.join(File.dirname(__FILE__), path)
    Dir.mkdir(full_path) unless File.exist?(full_path)
    extension = @@energysparksanalyticsautotest.key?(:name_extension) ? ('- ' + @@energysparksanalyticsautotest[:name_extension].to_s) : ''
    yaml_filename = full_path + @school_name + '-' + chart_name.to_s + extension + '.yaml'
    yaml_filename.length > 259 ? shorten_filename(yaml_filename) : yaml_filename
  end

  # deal with Windows 260 character filepath limit
  def shorten_filename(yaml_filename)
    yaml_filename.gsub(/ School/,'').gsub(/ Community/,'')
  end

  def do_charts_internal(chart_name, chart_override)
    if chart_name.is_a?(Symbol)
      logger.debug self.class.banner(chart_name.to_s)
    else
      logger.debug "Running Composite Chart #{chart_name[:name]}"
    end
    chart_results = nil
    bm = Benchmark.measure {
      chart_results = @chart_manager.run_chart_group(chart_name, chart_override)
    }
    @benchmarks.push(sprintf("%20.20s %40.40s = %s", @school.name, chart_name, bm.to_s))
    if chart_results.nil?
      @failed_reports.push([@school.name, chart_name])
      puts "Nil chart result from #{chart_name}"
    end
    if chart_name.is_a?(Symbol)
      [chart_results]
    else
      chart_results[:charts]
    end
  end
end
