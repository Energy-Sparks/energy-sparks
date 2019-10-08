class RenameAlertTypeDescription < ActiveRecord::Migration[6.0]
  def change
    rename_column :alert_types, :description, :_old_description
    change_column_null :alert_types, :_old_description, true
  end
end
