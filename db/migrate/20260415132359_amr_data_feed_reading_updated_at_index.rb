# frozen_string_literal: true

class AmrDataFeedReadingUpdatedAtIndex < ActiveRecord::Migration[7.2]
  def change
    # Supports querying for the latest amr data feed reading for specific configs
    add_index :amr_data_feed_readings, %i[amr_data_feed_config_id updated_at], name: :idx_readings_config_id_updated_at
  end
end
