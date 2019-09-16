# == Schema Information
#
# Table name: academic_years
#
#  calendar_area_id :bigint(8)        not null
#  calendar_id      :integer
#  end_date         :date
#  id               :bigint(8)        not null, primary key
#  start_date       :date
#
# Indexes
#
#  index_academic_years_on_calendar_area_id  (calendar_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (calendar_area_id => calendar_areas.id) ON DELETE => cascade
#

class AcademicYear < ApplicationRecord
  has_many :calendar_events
  belongs_to :calendar_area

  scope :for_date, ->(date) { where('start_date <= ? AND end_date >= ?', date, date) }

  def current?(today = Time.zone.today)
    (start_date <= today) && (end_date >= today)
  end

  def title
    "#{start_date.year} - #{end_date.year}"
  end
end
