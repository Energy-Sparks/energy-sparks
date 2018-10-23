class CreateAmrDataFeedReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :amr_data_feed_readings do |t|
      t.integer     :amr_data_feed_config_id,  null: false
      t.integer     :meter_id
      t.bigint      :mpan_mprn,     null: false
      t.date        :reading_date,  null: false
      t.decimal     :readings,      null: false, array: true
      t.text        :postcode
      t.text        :school
      t.text        :description
      t.text        :units
      t.decimal     :total
      t.text        :meter_serial_number
      t.text        :provider_record_id
      t.text        :type
      t.timestamps
    end

    add_foreign_key :amr_data_feed_readings, :amr_data_feed_configs, name: "amr_data_feed_readings_config_id_fk" if table_exists?(:amr_data_feed_configs)
  end
end

