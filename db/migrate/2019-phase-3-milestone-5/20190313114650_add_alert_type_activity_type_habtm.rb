class AddAlertTypeActivityTypeHabtm < ActiveRecord::Migration[5.2]
  def change
    create_join_table :activity_types, :alert_types do |t|
      t.index [:alert_type_id, :activity_type_id], unique: true, name: 'activity_alert_uniq'
    end
  end
end
