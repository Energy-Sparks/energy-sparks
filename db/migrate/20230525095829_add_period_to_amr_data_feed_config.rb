class AddPeriodToAmrDataFeedConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :period_field, :string, default: nil
  end
end
