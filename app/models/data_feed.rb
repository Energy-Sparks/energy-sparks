require 'csv'
# == Schema Information
#
# Table name: data_feeds
#
#  area_id       :integer
#  configuration :json             not null
#  description   :text
#  id            :bigint(8)        not null, primary key
#  title         :text
#  type          :text             not null
#
# Indexes
#
#  index_data_feeds_on_area_id  (area_id)
#

class DataFeed < ApplicationRecord
  belongs_to  :area
  has_many    :data_feed_readings

  def to_csv(feed_type, start_date = DateTime.yesterday - 1, end_date = DateTime.yesterday)
    readings = data_feed_readings.where(feed_type: feed_type).where('at >= ? and at <= ?', start_date, end_date)

    CSV.generate(headers: true) do |csv|
      csv << %w(DateTime Value)
      readings.each do |f|
        csv << [f.at.strftime('%Y-%m-%d %H:%M'), f.value]
      end
    end
  end
end
