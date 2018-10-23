class CreateAmrDataFeedConfigTable < ActiveRecord::Migration[5.2]
  def change
    create_table :amr_data_feed_configs do |t|
      t.integer :area_id
      t.text    :description,         null: false
      t.text    :bucket,              null: false
      t.text    :archive_bucket,      null: false
      t.text    :access_type,         null: false
      t.text    :date_format,         null: false
      t.text    :mpan_mprn_field,     null: false
      t.text    :reading_date_field,  null: false
      t.text    :reading_fields,      null: false, array: true
      t.text    :msn_field
      t.text    :provider_id_field
      t.text    :total_field
      t.text    :meter_description_field
      t.text    :postcode_field
      t.text    :units_field
      t.text    :headers_example
      t.timestamps
    end

    #add_foreign_key :amr_data_feed_configs, :areas, name: "amr_data_feed_configs_areas_id_fk" if table_exists?(:areas)

  end
end
