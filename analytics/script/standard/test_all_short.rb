require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

ENV['ENERGYSPARKSMETERCOLLECTIONDIRECTORY'] += '\Benchmark'
ENV['ANALYTICSTESTRESULTDIR']               += '\BenchmarkResults'

run_date = Date.new(2021, 12, 10)

script = {
  logger1:                  { name: TestDirectory.instance.log_directory + "/datafeeds %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
  # ruby_profiler:            true,
  schools:                  ['*'],
  source:                   :unvalidated_meter_data,
  logger2:                  { name: "./log/reports %{school_name} %{time}.log", format: "%{datetime} %{severity.ljust(5, ' ')}: %{msg}\n" },

  management_summary_table:          {
    control: {
      combined_html_output_file:     "Management Summary Table #{Date.today}",
      compare_results: [
        { comparison_directory: ENV['ANALYTICSTESTRESULTDIR'] + '\Management Summary Table\Base' },
        { output_directory:     ENV['ANALYTICSTESTRESULTDIR'] + '\Management Summary Table\New' },
        :summary,
        :report_differences
      ]
    }
  },

  alerts:                   {
    alerts: nil,
    control:  {
                compare_results: {
                  summary:              :differences, # true || false || :detail || :differences
                  report_if_differs:    true,
                  methods:              %i[raw_variables_for_saving],   # %i[ raw_variables_for_saving front_end_template_data front_end_template_chart_data front_end_template_table_data
                  class_methods:        %i[front_end_template_variables],
                  comparison_directory: ENV['ANALYTICSTESTRESULTDIR'] + '\Alerts\Base',
                  output_directory:     ENV['ANALYTICSTESTRESULTDIR'] + '\Alerts\New'
                },

                charts: {
                  calculate:      true,
                  write_to_excel: true
                },

                log: %i[:failed_calculations], # :sucessful_calculations, :invalid_alerts

                no_outputs:     %i[front_end_template_variables front_end_template_data front_end_template_tables front_end_template_table_data], # front_end_template_variables front_end_template_data raw_variables_for_saving],
                asof_date:      run_date
              }
  },

  adult_dashboard:          {
    control: {
      root:    :adult_analysis_page, # :pupil_analysis_page,
      display_average_calculation_rate: true,
      summarise_differences: false,
      report_failed_charts:   :summary,
      page_calculation_time: false,
      user: { user_role: nil, staff_role: nil },
      compare_results: [
        { comparison_directory: ENV['ANALYTICSTESTRESULTDIR'] + '\AdultDashboard\Base' },
        { output_directory:     ENV['ANALYTICSTESTRESULTDIR'] + '\AdultDashboard\New' },
        :summary,
      ]
    }
  },

  equivalences:          {
    control: {
      periods: [
        {year: 0},
        {workweek: 0},
        {week: 0},
        {schoolweek: 0},
        {schoolweek: -1},
        {month: 0},
        {month: -1}
      ],
      compare_results: [
        { comparison_directory: ENV['ANALYTICSTESTRESULTDIR'] + '\Equivalences\Base\\' },
        { output_directory:     ENV['ANALYTICSTESTRESULTDIR'] + '\Equivalences\New\\' }
      ]
    }
  },
}

RunTests.new(script).run
