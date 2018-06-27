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
  has_many    :data_feed_readings, dependent: :destroy

  def to_csv(output_readings)
    CSV.generate(headers: true, col_sep: "\t", encoding: 'ISO-8859-1') do |csv|
      csv << %w(DateTime Value)
      output_readings.each do |f|
        csv << [f.at.strftime('%Y-%m-%d %H:%M'), f.value]
      end
    end
  end

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
    data_feed_readings.where(feed_type: feed_type).where('at >= ? and at <= ?', start_date, end_date).order(at:)
  end
end
