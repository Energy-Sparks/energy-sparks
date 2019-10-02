class MoveAssociatedActivitiesToAlertTypeRatings < ActiveRecord::Migration[6.0]
  def change

    rename_table :alert_type_activity_types, :alert_type_rating_activity_types
    add_reference :alert_type_rating_activity_types, :alert_type_rating, foreign_key: {on_delete: :cascade}

    reversible do |dir|
      dir.up do
        connection.execute(
          'UPDATE alert_type_rating_activity_types SET alert_type_rating_id = alert_type_ratings.id FROM alert_type_ratings WHERE alert_type_ratings.alert_type_id = alert_type_rating_activity_types.alert_type_id'
        )
        connection.execute(
          'DELETE FROM alert_type_rating_activity_types WHERE alert_type_rating_id IS NULL'
        )
      end
    end

    change_column_null :alert_type_rating_activity_types, :alert_type_rating_id, false
    remove_reference :alert_type_rating_activity_types, :alert_type

  end
end
