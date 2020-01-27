class AddExpectedUnitsToAmrDataFeedConfigs < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_data_feed_configs, :expected_units, :string
  end
end
