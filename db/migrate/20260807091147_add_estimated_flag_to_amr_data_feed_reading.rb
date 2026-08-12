# frozen_string_literal: true

class AddEstimatedFlagToAmrDataFeedReading < ActiveRecord::Migration[8.1]
  def change
    add_column :amr_data_feed_readings, :estimated, :boolean, null: false, default: false

    change_table :amr_data_feed_configs, bulk: true do |t|
      t.string :reading_status_fields, array: true, null: false, default: []
      t.string :estimate_flags, array: true, null: false, default: []
      t.boolean :repeated_names, null: false, default: false
    end
  end
end
