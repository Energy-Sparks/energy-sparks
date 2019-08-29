class AddRowPerReadingConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :row_per_reading, :boolean, default: false
  end
end
