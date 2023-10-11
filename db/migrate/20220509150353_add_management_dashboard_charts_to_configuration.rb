class AddManagementDashboardChartsToConfiguration < ActiveRecord::Migration[6.0]
  def change
    # a list of chart names that should be displayed on this schools dashboard
    add_column :configurations, :dashboard_charts, :string, array: true, null: false, default: []
  end
end
