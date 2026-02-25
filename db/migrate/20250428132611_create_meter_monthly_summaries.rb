class CreateMeterMonthlySummaries < ActiveRecord::Migration[7.2]
  def change
    create_enum :meter_monthly_summary_type, %i[consumption generation self_consume export]
    create_enum :meter_monthly_summary_quality, %i[incomplete actual estimated corrected]

    create_table :meter_monthly_summaries do |t|
      t.references :meter, null: false
      t.integer :year, null: false
      t.enum :type, enum_type: :meter_monthly_summary_type, null: false
      t.float :consumption, array: true, null: false
      t.enum :quality, array: true, enum_type: :meter_monthly_summary_quality, null: false
      t.float :total, null: false

      t.timestamps
    end
    add_index :meter_monthly_summaries, %i[meter_id year type], unique: true
  end
end
