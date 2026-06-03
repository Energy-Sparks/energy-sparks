class AddHalfHourlyLabellingToDataFeedConfig < ActiveRecord::Migration[7.1]
  def up
    create_enum :half_hourly_labelling, ["start", "end"]
    add_column :amr_data_feed_configs, :half_hourly_labelling, :enum, enum_type: :half_hourly_labelling, default: nil, null: true
  end

  def down
    remove_column :amr_data_feed_configs, :half_hourly_labelling
    drop_enum :half_hourly_labelling
  end
end
