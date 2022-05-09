class DropDashboardChartTypeColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :configurations, :electricity_dashboard_chart_type
    remove_column :configurations, :gas_dashboard_chart_type
    remove_column :configurations, :storage_heater_dashboard_chart_type
  end
end
