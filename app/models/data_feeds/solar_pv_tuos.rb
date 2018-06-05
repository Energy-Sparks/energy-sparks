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

# TUOS is The University of Sheffield
class DataFeeds::SolarPvTuos < DataFeed
  belongs_to :solar_pv_tuos_area
end
