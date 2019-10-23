class CreateAmrValidatedReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :amr_validated_readings do |t|
      t.references    :meter,                   null: false, foreign_key: true
      t.decimal       :kwh_data_x48,            null: false, array: true
      t.decimal       :one_day_kwh,             null: false
      t.date          :reading_date,            null: false
      t.text          :status,                  null: false
      t.date          :substitute_date
      t.datetime      :upload_datetime
    end
  end
end
