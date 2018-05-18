# == Schema Information
#
# Table name: areas
#
#  calendar         :boolean          default(TRUE)
#  description      :text
#  id               :bigint(8)        not null, primary key
#  met_office       :boolean          default(FALSE)
#  parent_area_id   :integer
#  solar_irradiance :boolean          default(FALSE)
#  solar_pv         :boolean          default(FALSE)
#  temperature      :boolean          default(FALSE)
#  title            :text
#
# Indexes
#
#  index_areas_on_parent_area_id  (parent_area_id)
#

class Area < ApplicationRecord
  belongs_to  :parent_area, class_name: 'Area'
  has_many    :child_areas, class_name: 'Area', foreign_key: :parent_area_id
end
