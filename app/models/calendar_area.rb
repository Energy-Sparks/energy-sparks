# == Schema Information
#
# Table name: areas
#
#  data_feed_id   :bigint(8)
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
#  index_areas_on_data_feed_id    (data_feed_id)
#  index_areas_on_parent_area_id  (parent_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (data_feed_id => data_feeds.id) ON DELETE => restrict
#

class CalendarArea < Area
  has_many    :schools
  has_many    :calendars
  has_many    :bank_holidays
  belongs_to  :parent_calendar_area, class_name: 'CalendarArea'
  has_many    :child_calendar_areas, class_name: 'CalendarArea', foreign_key: :parent_area_id

  scope :with_template, -> { includes(:calendars).where(calendars: { template: true })}

  validates :title, presence: true
end
