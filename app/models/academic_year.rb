# == Schema Information
#
# Table name: academic_years
#
#  calendar_id :integer
#  end_date    :date
#  id          :bigint(8)        not null, primary key
#  start_date  :date
#
# Foreign Keys
#
#  fk_rails_...  (calendar_id => calendars.id) ON DELETE => restrict
#

class AcademicYear < ApplicationRecord
  has_many :calendar_events
  belongs_to :calendar

  scope :for_date, ->(date) { where('start_date <= ? AND end_date >= ?', date, date) }
  scope :for_date_onwards, ->(date) { where('end_date >= ? AND start_date <= ?', date, Time.zone.today) }
  scope :ordered, ->(order = :asc) { order(start_date: order) }

  def self.current
    for_date(Time.zone.today).first
  end

  def current?(today = Time.zone.today)
    (start_date <= today) && (end_date >= today)
  end

  def previous?(today = Time.zone.today)
    end_date < today
  end

  def previous_year
    AcademicYear.for_date(self.start_date - 1).where(calendar: self.calendar).reject(&:current?).first
  end

  def next_year
    AcademicYear.for_date(self.end_date + 1).where(calendar: self.calendar).reject(&:current?).first
  end

  def title
    "#{start_date.year} - #{end_date.year}"
  end
end
