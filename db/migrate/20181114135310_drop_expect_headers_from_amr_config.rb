class DropExpectHeadersFromAmrConfig < ActiveRecord::Migration[5.2]
  def change
    remove_column :amr_data_feed_configs, :expect_header, :boolean
  end
end
