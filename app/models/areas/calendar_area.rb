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

class CalendarArea < Area
  has_many :schools
  has_many :calendars
  has_many :bank_holidays
  belongs_to  :parent_calendar_area, class_name: 'CalendarArea'
  has_many    :child_calendar_areas, class_name: 'CalendarArea', foreign_key: :parent_area_id
end
