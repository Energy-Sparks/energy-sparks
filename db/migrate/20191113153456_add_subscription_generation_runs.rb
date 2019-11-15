class AddSubscriptionGenerationRuns < ActiveRecord::Migration[6.0]
  def up
    create_table :subscription_generation_runs do |t|
      t.references :school, foreign_key: {on_delete: :cascade}, null: false
      t.references :content_generation_run, null: false
      t.timestamps
    end

    add_reference :alert_subscription_events, :subscription_generation_run, foreign_key: {on_delete: :cascade}, index: {name: 'ase_sgr_index'}

    connection.execute "INSERT INTO subscription_generation_runs (school_id, content_generation_run_id, created_at, updated_at) (SELECT content_generation_runs.school_id, content_generation_runs.id, content_generation_runs.created_at, content_generation_runs.updated_at FROM content_generation_runs INNER JOIN alert_subscription_events ON alert_subscription_events.content_generation_run_id = content_generation_runs.id)"
    connection.execute "UPDATE alert_subscription_events SET subscription_generation_run_id = subscription_generation_runs.id FROM subscription_generation_runs WHERE subscription_generation_runs.content_generation_run_id  = alert_subscription_events.content_generation_run_id"

    remove_column :alert_subscription_events, :content_generation_run_id
    remove_column :subscription_generation_runs, :content_generation_run_id

    change_column_null :alert_subscription_events, :subscription_generation_run_id, false
  end
end
