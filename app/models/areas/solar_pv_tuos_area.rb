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

# TUOS is The University of Sheffield
class SolarPvTuosArea < Area
  has_many :data_feeds, class_name: 'DataFeeds::SolarPvTuos', foreign_key: :area_id
end
