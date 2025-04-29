class CreateMeterMonthlySummaries < ActiveRecord::Migration[7.2]
  def change
    # create_enum :meter_monthly_summary_type, ["anyone", "school_users", "school_admins", "group_admins"]
    create_enum :meter_monthly_summary_quality, %i[incomplete actual estimated corrected]

    create_table :meter_monthly_summaries do |t|
      t.references :meter

      t.integer :year
      # t.enum :type, enum_type: :meter_monthly_summary_type

      t.float :consumption, array: true
      t.enum :quality, array: true, enum_type: :meter_monthly_summary_quality
      t.float :total

      t.timestamps
    end
  end
end
