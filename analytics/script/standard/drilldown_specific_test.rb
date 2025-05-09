require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

schools = ['chase-from*']

script = {
  logger1:                  { name: TestDirectory.instance.log_directory + "/drilldownspecific %{time}.log", format: "%{severity.ljust(5, ' ')}: %{msg}\n" },
  schools:  schools,
  source:   :unvalidated_meter_data,
  specific_drilldowns: [
    {
      charts: [ # Excel_worksheet_name: [list of charts]
         { ttculm:   %i[targeting_and_tracking_weekly_electricity_to_date_cumulative_line] }
      ],
      drilldown_columns: [[40, 3]] # drilldown on column 40 on the 1st drilldown then column 5 on the second
    }
  ]
}

RunTests.new(script).run
