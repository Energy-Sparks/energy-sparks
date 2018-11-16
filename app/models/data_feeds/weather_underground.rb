# == Schema Information
#
# Table name: data_feeds
#
#  area_id       :bigint(8)
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

class DataFeeds::WeatherUnderground < DataFeed
  belongs_to :weather_underground_area
end
