# == Schema Information
#
# Table name: areas
#
#  data_feed_id :bigint(8)
#  description  :text
#  id           :bigint(8)        not null, primary key
#  latitude     :decimal(10, 6)
#  longitude    :decimal(10, 6)
#  title        :text
#  type         :text             not null
#
# Indexes
#
#  index_areas_on_data_feed_id  (data_feed_id)
#
# Foreign Keys
#
#  fk_rails_...  (data_feed_id => data_feeds.id) ON DELETE => restrict
#

# TUOS is The University of Sheffield
class SolarPvTuosArea < Area
  belongs_to :data_feed, class_name: 'DataFeeds::SolarPvTuos', foreign_key: :data_feed_id
  has_many :solar_pv_tuos_readings
end
