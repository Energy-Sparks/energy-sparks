class AddComparisonReportToAlerts < ActiveRecord::Migration[6.1]
  def change
    add_reference :alerts, :comparison_report, foreign_key: { to_table: 'comparison_reports' }
    add_reference :alert_errors, :comparison_report, foreign_key: { to_table: 'comparison_reports' }
  end
end
