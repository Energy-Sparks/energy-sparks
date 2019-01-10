# == Schema Information
#
# Table name: calendars
#
#  based_on_id      :bigint(8)
#  calendar_area_id :bigint(8)
#  created_at       :datetime         not null
#  default          :boolean
#  deleted          :boolean          default(FALSE)
#  id               :bigint(8)        not null, primary key
#  template         :boolean          default(FALSE)
#  title            :string           not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_calendars_on_based_on_id  (based_on_id)
#

class Calendar < ApplicationRecord
  belongs_to  :calendar_area
  has_many    :calendar_events, dependent: :destroy

  belongs_to  :based_on, class_name: 'Calendar'
  has_many    :calendars, class_name: 'Calendar', foreign_key: :based_on_id

  has_many    :schools

  default_scope { where(deleted: false) }

  scope :template,  -> { where(template: true) }
  scope :custom,    -> { where(template: false) }

  validates_presence_of :title

  accepts_nested_attributes_for :calendar_events, reject_if: :reject_calendar_events, allow_destroy: true

  def reject_calendar_events(attributes)
    end_date_date = Date.parse(attributes[:end_date])
    end_date_default = end_date_date.month == 8 && end_date_date.day == 31
    attributes[:title].blank? || attributes[:start_date].blank? || end_date_default
  end

  def terms
    calendar_events.terms
  end

  def holidays
    calendar_events.holidays
  end

  def bank_holidays
    calendar_events.bank_holidays
  end

  def inset_days
    calendar_events.inset_days
  end

  def self.default_calendar
    Calendar.find_by(default: true)
  end

  def first_event_date
    calendar_events.first.start_date
  end

  def last_event_date
    calendar_events.last.end_date
  end

  def next_holiday
    holidays.where('start_date > ?', Time.zone.today).order(start_date: :asc).first
  end

  def holiday_approaching?
    next_holiday.start_date == Time.zone.today + 3.days
  end
end

# As a reminder!
# c.calendar_events.joins(:calendar_event_type).group('calendar_event_types.title').order('calendar_event_types.title').count
