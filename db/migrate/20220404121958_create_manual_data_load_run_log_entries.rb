class CreateManualDataLoadRunLogEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :manual_data_load_run_log_entries do |t|
      t.references :manual_data_load_run, null: false, foreign_key: true, index: { name: :manual_data_load_run_log_idx }
      t.string :message
      t.timestamps
    end
  end
end
