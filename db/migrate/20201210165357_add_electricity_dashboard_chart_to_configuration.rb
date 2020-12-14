class AddElectricityDashboardChartToConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column(:configurations, :electricity_dashboard_chart_type, :integer, null: false, default: 0)
  end
end
