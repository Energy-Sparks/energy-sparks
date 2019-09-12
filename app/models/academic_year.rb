# == Schema Information
#
# Table name: academic_years
#
#  calendar_id :integer
#  end_date    :date
#  id          :bigint(8)        not null, primary key
#  start_date  :date
#

class AcademicYear < ApplicationRecord
  has_many :calendar_events
  belongs_to :calendar, optional: true

  scope :for_date, ->(date) { where('start_date <= ? AND end_date >= ?', date, date) }

  def current?(today = Time.zone.today)
    (start_date <= today) && (end_date >= today)
  end

  def title
    "#{start_date.year} - #{end_date.year}"
  end
end
