class AddPositionToActivityAlertTypesHabtm < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_types_alert_types, :id, :primary_key
    add_column :activity_types_alert_types, :position, :integer, default: 0, null: false
    rename_table :activity_types_alert_types, :alert_type_activity_types
  end
end
