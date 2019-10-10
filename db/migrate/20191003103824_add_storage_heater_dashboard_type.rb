class AddStorageHeaterDashboardType < ActiveRecord::Migration[6.0]
  def change
    add_column :configurations, :storage_heater_dashboard_chart_type, :integer, default: 0, null: false
  end
end
