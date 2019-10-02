class ChangeBelongsToNulls < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        connection.execute 'DELETE FROM calendar_events WHERE academic_year_id IS NULL'
      end
    end
    change_column_null :activities, :school_id, false
    change_column_null :activities, :activity_type_id, false
    change_column_null :activity_types, :activity_category_id, false
    change_column_null :activity_type_suggestions, :suggested_type_id, false
    change_column_null :alerts, :alert_type_id, false
    change_column_null :alerts, :school_id, false
    change_column_null :alert_subscription_events, :alert_id, false
    change_column_null :alert_subscription_events, :alert_type_rating_content_version_id, false
    change_column_null :alert_subscription_events, :contact_id, false
    change_column_null :amr_data_feed_import_logs, :amr_data_feed_config_id, false
    change_column_null :amr_data_feed_readings, :amr_data_feed_import_log_id, false
    change_column_null :amr_data_feed_readings, :amr_data_feed_config_id, false
    change_column_null :bank_holidays, :calendar_area_id, false
    change_column_null :calendar_events, :academic_year_id, false
    change_column_null :calendar_events, :calendar_event_type_id, false
    change_column_null :contacts, :school_id, false
    change_column_null :data_feed_readings, :data_feed_id, false
    change_column_null :meters, :school_id, false
    change_column_null :programmes, :programme_type_id, false
    change_column_null :programmes, :school_id, false
    change_column_null :school_times, :school_id, false
    change_column_null :simulations, :school_id, false
    change_column_null :simulations, :user_id, false
  end
end
