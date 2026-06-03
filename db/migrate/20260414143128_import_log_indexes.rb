# frozen_string_literal: true

class ImportLogIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :amr_data_feed_import_logs, :import_time
  end
end
