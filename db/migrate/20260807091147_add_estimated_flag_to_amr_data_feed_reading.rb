# frozen_string_literal: true

class AddEstimatedFlagToAmrDataFeedReading < ActiveRecord::Migration[8.1]
  def change
    add_column :amr_data_feed_readings, :estimated, :boolean, null: false, default: false
  end
end
