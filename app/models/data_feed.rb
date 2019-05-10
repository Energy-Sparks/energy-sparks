# == Schema Information
#
# Table name: data_feeds
#
#  configuration :json             not null
#  description   :text
#  id            :bigint(8)        not null, primary key
#  title         :text
#  type          :text             not null
#

class DataFeed < ApplicationRecord
  belongs_to  :area
  has_many    :data_feed_readings, dependent: :destroy

  def first_reading(feed_type)
    data_feed_readings.where(feed_type: feed_type).order(at: :asc).limit(1).first
  end

  def last_reading
    data_feed_readings.order(at: :desc).limit(1).first
  end

  def last_reading_time
    last_reading.at
  end

  def readings(feed_type, start_date = DateTime.yesterday - 1, end_date = DateTime.yesterday)
    data_feed_readings.where(feed_type: feed_type).where('at >= ? and at <= ?', start_date.beginning_of_day, end_date.end_of_day).order(:at)
  end
end
