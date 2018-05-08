class CreateMeterReadings < ActiveRecord::Migration[5.0]
  def change
    create_table :meter_readings do |t|
      t.references :meter, foreign_key: true
      t.datetime :read_at, index: true
      t.decimal :value
      t.string :unit

      t.timestamps
    end
  end
end
