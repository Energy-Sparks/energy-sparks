# == Schema Information
#
# Table name: areas
#
#  description    :text
#  id             :bigint(8)        not null, primary key
#  latitude       :decimal(10, 6)
#  longitude      :decimal(10, 6)
#  parent_area_id :bigint(8)
#  title          :text
#  type           :text             not null
#
# Indexes
#
#  index_areas_on_parent_area_id  (parent_area_id)
#

class Area < ApplicationRecord
  belongs_to  :parent_area, class_name: 'Area'
  has_many    :child_areas, class_name: 'Area', foreign_key: :parent_area_id
end
