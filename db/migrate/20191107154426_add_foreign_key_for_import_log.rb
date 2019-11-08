class AddForeignKeyForImportLog < ActiveRecord::Migration[6.0]
  def change
    remove_index :amr_data_feed_readings, :amr_data_feed_import_log_id
    add_foreign_key :amr_data_feed_readings, :amr_data_feed_import_logs, on_delete: :cascade
  end
end

