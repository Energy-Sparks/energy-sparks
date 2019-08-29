class AddRowPerReadingConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :row_per_reading,        :boolean, default: false, null: false
    add_column :amr_data_feed_configs, :number_of_header_rows,  :integer, default: 0,     null: false
  end
end
