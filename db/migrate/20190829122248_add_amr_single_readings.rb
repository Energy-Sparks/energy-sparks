class AddAmrSingleReadings < ActiveRecord::Migration[6.0]
  def change
    create_table :amr_single_readings do |t|
      t.references    :amr_data_feed_config
      t.references    :meter
      t.references    :amr_data_feed_import_log
      t.text          :mpan_mprn,                 null: false
      t.text          :reading_date_time_as_text, null: false
      t.datetime      :reading_date_time,         null: false
      t.text          :reading,                   null: false
      t.integer       :reading_type,              null: false
      t.timestamps
    end

    add_index :amr_single_readings, [:mpan_mprn, :reading_date_time_as_text], unique: true,  name: 'amr_single_readings_uniq'

  end
end
