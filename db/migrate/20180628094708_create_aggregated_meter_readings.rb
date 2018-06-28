class CreateAggregatedMeterReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :aggregated_meter_readings do |t|
      t.references  :meter,       foreign_key: true
      t.decimal     :readings,    array: true
      t.date        :when,        null: false
      t.decimal     :total,       default: 0.0
      t.boolean     :verified,    default: false
      t.boolean     :substitute,  default: false
    end
  end
end
