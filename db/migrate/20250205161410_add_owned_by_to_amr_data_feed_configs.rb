class AddOwnedByToAmrDataFeedConfigs < ActiveRecord::Migration[7.2]
  def change
    add_reference :amr_data_feed_configs, :owned_by, foreign_key: { to_table: :users }
  end
end
