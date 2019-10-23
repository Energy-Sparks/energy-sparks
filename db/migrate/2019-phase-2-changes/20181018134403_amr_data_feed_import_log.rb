class AmrDataFeedImportLog < ActiveRecord::Migration[5.2]
  def change
    create_table :amr_data_feed_import_logs do |t|
      t.references :amr_data_feed_config
      t.text       :file_name
      t.datetime   :import_time
      t.integer    :records_imported
      t.timestamps
    end
  end
end
