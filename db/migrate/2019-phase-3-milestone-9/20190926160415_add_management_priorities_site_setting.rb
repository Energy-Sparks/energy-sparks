class AddManagementPrioritiesSiteSetting < ActiveRecord::Migration[6.0]
  def change
    add_column :site_settings, :management_priorities_limit, :integer, default: 10
  end
end
