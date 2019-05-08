# == Schema Information
#
# Table name: areas
#
#  description    :text
#  id             :bigint(8)        not null, primary key
#  parent_area_id :integer
#  title          :text
#  type           :text             not null
#
# Indexes
#
#  index_areas_on_parent_area_id  (parent_area_id)
#

class WeatherUndergroundArea < Area
  belongs_to :data_feed, class_name: 'DataFeeds::WeatherUnderground', foreign_key: :data_feed_id
end
