class CreateAmrDataFeedReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :amr_data_feed_readings do |t|
      t.references     :amr_data_feed_config
      t.references     :meter
      t.bigint      :mpan_mprn,     null: false
      t.date        :reading_date,  null: false
      t.decimal       :readings,      null: false, precision: 11, scale: 5, array: true
      t.decimal       :total,                      precision: 11, scale: 5
      t.text        :postcode
      t.text        :school
      t.text        :description
      t.text        :units
      t.text        :meter_serial_number
      t.text        :provider_record_id
      t.text        :type
      t.timestamps
    end
  end
end

