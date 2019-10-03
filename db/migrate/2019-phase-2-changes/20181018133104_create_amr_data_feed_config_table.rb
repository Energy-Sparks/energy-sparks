class CreateAmrDataFeedConfigTable < ActiveRecord::Migration[5.2]
  def change
    create_table :amr_data_feed_configs do |t|
      t.references :area
      t.text    :description,           null: false
      t.text    :s3_folder,             null: false
      t.text    :s3_archive_folder,     null: false
      t.text    :local_bucket_path,     null: false
      t.text    :access_type,           null: false
      t.text    :date_format,           null: false
      t.text    :mpan_mprn_field,       null: false
      t.text    :reading_date_field,    null: false
      t.text    :reading_fields,        null: false, array: true
      t.text    :column_separator,      null: false, default: ','
      t.text    :msn_field
      t.text    :provider_id_field
      t.text    :total_field
      t.text    :meter_description_field
      t.text    :postcode_field
      t.text    :units_field
      t.text    :header_example
      t.boolean :expect_header,        null: false, default: true
      t.timestamps
    end
  end
end
