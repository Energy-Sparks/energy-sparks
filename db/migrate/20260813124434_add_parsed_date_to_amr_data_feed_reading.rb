# frozen_string_literal: true

class AddParsedDateToAmrDataFeedReading < ActiveRecord::Migration[8.1]
  def change
    add_column :amr_data_feed_readings, :parsed_date, :date
  end
end
