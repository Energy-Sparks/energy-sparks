class CreateSchoolBatchRuns < ActiveRecord::Migration[6.0]
  def change
    create_table :school_batch_runs do |t|
      t.references :school, foreign_key: {on_delete: :cascade}
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
