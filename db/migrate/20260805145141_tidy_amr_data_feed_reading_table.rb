# frozen_string_literal: true

class TidyAmrDataFeedReadingTable < ActiveRecord::Migration[8.1]
  def change
    change_table :amr_data_feed_configs, bulk: true do |t|
      t.remove :meter_description_field, type: :text
      t.remove :postcode_field, type: :text
      t.remove :provider_id_field, type: :text
      t.remove :total_field, type: :text
    end

    change_table :amr_data_feed_readings, bulk: true do |t|
      t.remove :description, type: :text
      t.remove :postcode, type: :text
      t.remove :provider_record_id, type: :text
      t.remove :reading_time, type: :text
      t.remove :school, type: :text
      t.remove :total, type: :text
      t.remove :type, type: :text
    end
  end
end
