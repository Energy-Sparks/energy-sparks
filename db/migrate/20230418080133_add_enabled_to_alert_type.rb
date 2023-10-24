class AddEnabledToAlertType < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_types, :enabled, :boolean, default: true, null: false
  end
end
