# test report manager
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'
require './script/report_config_support.rb'

script = {
  logger1:                  { name: TestDirectory.instance.log_directory + "/datafeeds %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
  schools:                   ['trini*'],
  source:                   :unvalidated_meter_data, # :dcc_n3rgy_override_with_files,
  logger2:                  { name: "./log/management summary %{school_name} %{time}.log", format: "%{datetime} %{severity.ljust(5, ' ')}: %{msg}\n" },
  management_summary_table2:          {
      control: {
        combined_html_output_file:     "Management Summary Table #{Date.today}",
        compare_results: [
          { comparison_directory: ENV['ANALYTICSTESTRESULTDIR'] + '\Management Summary Table\Base' },
          { output_directory:     ENV['ANALYTICSTESTRESULTDIR'] + '\Management Summary Table\New' },
          :summary,
          :report_differences
        ]
      }
    }
}

RunTests.new(script).run
