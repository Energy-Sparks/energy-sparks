class MoveDashboardTitlesToOwnObject < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_type_ratings, :teacher_dashboard_alert_active, :boolean, default: false
    add_column :alert_type_ratings, :pupil_dashboard_alert_active, :boolean, default: false

    rename_table :find_out_more_calculations, :content_generation_runs
    rename_column :find_out_mores, :find_out_more_calculation_id, :content_generation_run_id

    create_table :dashboard_alerts do |t|
      t.integer    :dashboard, null: false # enum: teacher, pupil etc
      t.references :content_generation_run, null: false, foreign_key: {on_delete: :cascade}
      t.references :alert, null: false, foreign_key: {on_delete: :cascade}
      t.references :alert_type_rating_content_version, null: false, foreign_key: {on_delete: :restrict}
      t.references :find_out_more, foreign_key: {on_delete: :nullify}
      t.timestamps
    end

    add_reference :alert_subscription_events, :find_out_more, foreign_key: {on_delete: :nullify}
    add_reference :alert_subscription_events, :content_generation_run, null: false, foreign_key: {on_delete: :cascade}

    reversible do |dir|
      dir.up do
        connection.execute("UPDATE alert_type_ratings SET teacher_dashboard_alert_active = 't' WHERE find_out_more_active IS TRUE")
        connection.execute("UPDATE alert_type_ratings SET pupil_dashboard_alert_active = 't' WHERE find_out_more_active IS TRUE")
        [0, 1].each do |dashboard|
          connection.execute(
            'INSERT INTO dashboard_alerts (dashboard, content_generation_run_id, alert_id, alert_type_rating_content_version_id, find_out_more_id, created_at, updated_at) ' \
            "SELECT #{dashboard}, content_generation_run_id, alert_id, alert_type_rating_content_version_id, id, created_at, updated_at FROM find_out_mores"
          )
        end
        connection.execute(
          'UPDATE alert_subscription_events SET find_out_more_id = find_out_mores.id  FROM find_out_mores ' \
          'WHERE find_out_mores.alert_type_rating_content_version_id = alert_subscription_events.alert_type_rating_content_version_id ' \
          'AND find_out_mores.alert_id = alert_subscription_events.alert_id'
        )
      end
    end

  end
end
