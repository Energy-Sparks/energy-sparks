# == Schema Information
#
# Table name: calendar_areas
#
#  id        :bigint(8)        not null, primary key
#  parent_id :bigint(8)
#  title     :string           not null
#

class CalendarArea < ApplicationRecord
  has_many    :schools
  has_many    :calendars
  has_many    :bank_holidays
  belongs_to  :parent_area, class_name: 'CalendarArea', foreign_key: :parent_id
  has_many    :child_areas, class_name: 'CalendarArea', foreign_key: :parent_id
  has_many    :academic_years

  scope :with_template, -> { includes(:calendars).where(calendars: { template: true })}

  validates :title, presence: true

  def academic_year_for(date)
    parent_area ? parent_area.academic_year_for(date) : academic_years.for_date(date).first
  end
end
