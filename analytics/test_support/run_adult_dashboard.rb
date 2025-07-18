class RunAdultDashboard < RunCharts

  def initialize(school)
    super(school, results_sub_directory_type: self.class.test_type)
  end

  def self.test_type
    'AdultDashboard'
  end

  def self.default_config
    self.superclass.default_config.merge({ adult_dashboard: self.adult_dashboard_default_config })
  end

  def self.adult_dashboard_default_config
    {
      control: {
        root:    :adult_analysis_page, # :pupil_analysis_page,
        no_chart_manipulation: %i[drilldown timeshift],
        display_average_calculation_rate: true,
        summarise_differences: true,
        report_failed_charts:   :summary, # :detailed
        page_calculation_time: false,
        user: { user_role: nil, staff_role: nil }, # { user_role: :analytics, staff_role: nil },

        no_pages: %i[baseload],
        compare_results: [
          :summary,
          # :report_differences,
          #:report_differing_charts,
        ] # :quick_comparison,
      }
    }
  end

  def run_flat_dashboard(control)
    @accordion_count = 0
    @all_html = ''
    differing_pages = {}

    pages = control.fetch(:pages, page_list)
    pages.each do |page|
      if DashboardConfiguration::ADULT_DASHBOARD_GROUP_CONFIGURATIONS.key?(page)
        differences = nil
        definition = DashboardConfiguration::ADULT_DASHBOARD_GROUP_CONFIGURATIONS[page]
        RecordTestTimes.instance.record_time(@school.name, 'energy analysis', page){
          differences = run_one_page(page, definition, control)
        }
        differing_pages[page] = !differences.nil? && !differences.empty?
      else
        puts "Not running page #{page}"
      end
    end
    save_to_excel
    write_html
    differing_pages
  end

  def self.summarise_differences(differences, _control)
    summarise_school_differences(differences)
    summarise_page_differences(differences)
  end

  private

  def self.summarise_school_differences(differences)
    puts "================Differences By School===================="
    differences.each do |school_name, page_differs|
      diff_count = page_differs.values.count{ |v| v }
      no_diff_count = page_differs.length - diff_count
      puts sprintf('%-30.30s: %3d differ %3d same', school_name, diff_count, no_diff_count)
    end
  end

  def self.summarise_page_differences(differences)
    by_page_type = calculate_page_differences(differences)
    print_page_differences(by_page_type)
  end

  def self.calculate_page_differences(differences)
    by_page_type = {}
    differences.each do |school_name, page_differs|
      page_differs.each do |page_name, differs|
        by_page_type[page_name] ||= {}

        by_page_type[page_name][true]  ||= 0
        by_page_type[page_name][false] ||= 0

        by_page_type[page_name][differs] += 1
      end
    end
    by_page_type
  end

  def self.print_page_differences(by_page_type)
    puts "================Differences By Page Type================="
    by_page_type.each do |page_name, stats|
      puts sprintf('%-30.30s: %3d differ %3d same', page_name, by_page_type[page_name][true], by_page_type[page_name][false])
    end
  end

  private def adult_report_groups
    report_groups = []
    report_groups.push(:benchmark)                    if @school.electricity? && !@school.solar_pv_panels?
    report_groups.push(:benchmark_kwh_electric_only)  if @school.electricity? && @school.solar_pv_panels?
    report_groups.push(:electric_group)               if @school.electricity?
    report_groups.push(:gas_group)                    if @school.gas?
    report_groups.push(:hotwater_group)               unless @school.heating_only?
    report_groups.push(:boiler_control_group)         unless @school.non_heating_only?
    report_groups.push(:storage_heater_group)         if @school.storage_heaters?
    # now part of electricity report_groups.push(:solar_pv_group)               if solar_pv_panels?
    report_groups.push(:carbon_group)                 # if electricity? && gas?
    report_groups.push(:energy_tariffs_group)         if false
    report_groups
  end

  private def page_list
    adult_report_groups.map do |report_group|
      DashboardConfiguration::ADULT_DASHBOARD_GROUPS[report_group]
    end.flatten
  end

  private def excel_variation
    '- adult dashboard'
  end

  private def run_one_page(page, definition, control)
    content = []
    logger.info "Running page #{page} has class #{definition.key?(:content_class)}"

    advice = definition[:content_class].new(@school)

    return unless valid?(advice, page)

    bm = Benchmark.realtime {
      advice.calculate

      return if calculation_failed?(advice, page)

      if advice.has_structured_content?(user_type: control[:user])
        content += [ accordion_style_css ]
        advice.structured_content(user_type: control[:user]).each do |component_advice|
          content += accordion_html(component_advice[:title], component_advice[:content])
        end
      else
        content = advice.content(user_type: control[:user])
      end
    }
    puts "#{sprintf('%20.20s', page)} = #{bm.round(3)}" if control[:page_calculation_time] == true


    @failed_charts.concat(advice.failed_charts)

    return if calculation_failed?(advice, page)

    differences = comparison_differences(control, @school.name, page, content)

    chart_names = content.select { |h| h[:type] == :chart_name }

    charts = chart_names.map { |chart_name| calculate_charts(chart_name) }

    working_charts = charts.select { |c| !c[:content].nil? }
    failed_charts  = charts.select { |c| c[:content].nil? }

    @failed_charts.concat(failed_charts)

    html, _deprecated_charts = advice.analytics_split_charts_and_html(content)

    worksheet_name = definition[:content_class].excel_worksheet_name

    @worksheets[worksheet_name] = working_charts.map { |c| c[:content] }
    @all_html += html.join(' ')
    differences
  end

  def comparison_differences(control, school_name, page, content)
    comparison = CompareContentResults.new(control, school_name, results_sub_directory_type: @results_sub_directory_type)

    comparison.save_and_compare_content(page, content, true)
  end

  # similar to front end:
  # https://github.com/Energy-Sparks/energy-sparks/blob/master/app/controllers/schools/charts_controller.rb
  # https://github.com/Energy-Sparks/energy-sparks/blob/master/app/models/chart_data.rb
  # variable naming convention and style to come extent mimics front end
  def calculate_charts(chart_definition)
    chart_name = original_chart_name = chart_definition[:content]
    config_overrides = {}

    if chart_definition.key?(:mpan_mprn)
      config_overrides =  { meter_definition: chart_definition[:mpan_mprn] }
      chart_name = (chart_name.to_s + "_#{chart_definition[:mpan_mprn]}").to_sym
    end

    begin
      chart_manager = ChartManager.new(@school)
      chart_config = chart_manager.get_chart_config(original_chart_name)
      transformed_chart_config = chart_config.merge(config_overrides)
      data = chart_manager.run_chart(transformed_chart_config, chart_name)

      { type: :chart, chart_name: chart_name, content: data }
    rescue => e
      puts "Chart #{chart_name} failed to calculate"
      logger.info "Chart #{chart_name} failed to calculate"
      logger.info e.backtrace
      { content: nil, school_name: @school.name, chart_name: chart_name,  message: e.message, backtrace: e.backtrace, type: e.class.name }
    end
  end

  # the id reference needs to be unique
  # for all the html otherwise the
  # 2nd+ instance fails to open
  def accordion_count
    @accordion_count += 1
  end

  def accordion_html(title, content)
    [
      accordion_start(title),
      content,
      accordion_end
    ].flatten
  end

  def accordion_start(title)
    if title.include?('&pound;')
      title, rhs = title.split('&pound;')
      rhs = '&pound;' + rhs
    end
    index = "accordionindex#{accordion_count}"
    text = %{
      <input type="checkbox" id="<%= index %>" />
      <label for="<%= index %>"><div class="split-para"><%= title %><span><%= rhs %></span></div></label>

      <div class="content">
    }
    { type: :html, content: ERB.new(text).result(binding) }
  end

  def accordion_end
    text = %{
      </div>
    }
    { type: :html, content: text }
  end

  def accordion_style_css
    {
      type: :html,
      content:  %{
                    <title>CSS Accordion</title>

                    <style>

                      input {
                          display: none;
                      }

                      label {
                          display: block;
                          padding: 8px 22px;
                          margin: 0 0 1px 0;
                          cursor: pointer;
                          background: #6AAB95;
                          border-radius: 3px;
                          color: #FFF;
                          transition: ease .5s;
                      }

                      label:hover {
                          background: #4E8774;
                      }

                      .content {
                          background: #FFFFFF;
                          padding: 10px 25px;
                          border: 1px solid #A7A7A7;
                          margin: 0 0 1px 0;
                          border-radius: 3px;
                      }

                      input + label + .content {
                          display: none;
                      }

                      input:checked + label + .content {
                          display: block;
                      }

                      .split-para      {
                        display:block;margin:10px;
                      }

                      .split-para span {
                        display:block;float:right;width:15%;margin-left:10px;
                      }

                      * {
                        transition: all .2s ease;
                      }

                      .extra-info {
                        display: none;
                        line-height: 30px;
                        font-size: 12px;
                        position: absolute;
                        top: 0;
                        left: 50px;
                      }

                      .info:hover .extra-info {
                        display: block;
                      }

                      .info {
                        font-size: 20px;
                        padding-left: 5px;
                        width: 20px;
                        border-radius: 15px;
                      }

                      .info:hover {
                        background-color: white;
                        padding: 0 0 0 5px;
                        width: 315px;
                        text-align: left !important;
                      }

                    </style>
                }
    }
  end

  def valid?(advice, page)
    unless advice.valid_alert?
      puts "                Page failed, as advice not valid #{page}"
      return false
    end

    unless advice.relevance == :relevant
      puts "                Page failed, as advice not relevant #{page}"
      return false
    end

    true
  end

  def calculation_failed?(advice, page)
    return false if advice.make_available_to_users?
    puts "                Page failed 1, as advice not available to users #{page}"
    true
  end

  def write_html(filename_suffix: '- adult dashboard')
    html_file = HtmlFileWriter.new(@school.name + filename_suffix, results_sub_directory_type: @results_sub_directory_type)
    html_file.write_header_footer('', @all_html, nil)
    html_file.close
  end
end
