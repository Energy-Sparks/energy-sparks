class AddFullPrioritySettings < ActiveRecord::Migration[6.0]
  def change
    rename_column :site_settings, :management_priorities_limit, :management_priorities_dashboard_limit
    change_column_default :site_settings, :management_priorities_dashboard_limit, from: 10, to: 5
    add_column :site_settings, :management_priorities_page_limit, :integer, default: 10
  end
end
