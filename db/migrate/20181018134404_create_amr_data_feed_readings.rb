class CreateAmrDataFeedReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :amr_data_feed_readings do |t|
      t.references    :amr_data_feed_config
      t.references    :meter
      t.references    :amr_data_feed_import_log
      t.text          :mpan_mprn,     null: false
      t.text          :reading_date,  null: false
      t.text          :readings,      null: false, array: true
      t.text          :total
      t.text          :postcode
      t.text          :school
      t.text          :description
      t.text          :units
      t.text          :meter_serial_number
      t.text          :provider_record_id
      t.text          :type
      t.timestamps
    end
  end
end
