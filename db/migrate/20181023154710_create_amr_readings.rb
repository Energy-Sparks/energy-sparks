class CreateAmrReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :amr_readings do |t|
      t.references  :meter,           null: false, foreign_key: true
      t.decimal       :kwh_data_x48,    precision: 11, scale: 5, null: false, array: true
      t.decimal       :one_day_kwh,     precision: 11, scale: 5, null: false
      t.date        :date,            null: false
      t.text        :status,          null: false
      t.date        :substitute_date
      t.datetime    :upload_datetime
    end
  end
end
