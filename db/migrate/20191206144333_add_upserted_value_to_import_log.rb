class AddUpsertedValueToImportLog < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_import_logs, :records_upserted, :integer, default: 0, null: false
  end
end
