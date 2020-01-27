class AddUserRestrictedColumnToAlertType < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_types, :user_restricted, :boolean, null: false, default: false
  end
end
