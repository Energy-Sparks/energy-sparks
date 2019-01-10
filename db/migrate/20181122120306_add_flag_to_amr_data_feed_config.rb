class AddFlagToAmrDataFeedConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :amr_data_feed_configs, :handle_off_by_one, :boolean, default: false
  end
end
