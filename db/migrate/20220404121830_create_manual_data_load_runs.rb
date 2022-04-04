class CreateManualDataLoadRuns < ActiveRecord::Migration[6.0]
  def change
    create_table :manual_data_load_runs do |t|
      t.references :amr_uploaded_reading, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
