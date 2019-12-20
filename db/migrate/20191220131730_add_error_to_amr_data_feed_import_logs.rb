class AddErrorToAmrDataFeedImportLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_import_logs, :error_messages, :text
  end
end
