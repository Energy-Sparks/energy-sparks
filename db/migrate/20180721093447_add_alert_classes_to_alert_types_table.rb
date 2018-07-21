class AddAlertClassesToAlertTypesTable < ActiveRecord::Migration[5.2]
  def change
    add_column :alert_types, :class_name, :text
  end
end
