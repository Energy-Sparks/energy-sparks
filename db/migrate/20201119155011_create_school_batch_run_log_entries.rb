class CreateSchoolBatchRunLogEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :school_batch_run_log_entries do |t|
      t.references :school_batch_run, foreign_key: {on_delete: :cascade}
      t.string :message
      t.timestamps
    end
  end
end
