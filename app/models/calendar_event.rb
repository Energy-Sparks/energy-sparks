# == Schema Information
#
# Table name: calendar_events
#
#  academic_year_id       :bigint(8)        not null
#  calendar_event_type_id :bigint(8)        not null
#  calendar_id            :bigint(8)        not null
#  description            :text
#  end_date               :date             not null
#  id                     :bigint(8)        not null, primary key
#  start_date             :date             not null
#  title                  :text
#
# Indexes
#
#  index_calendar_events_on_academic_year_id        (academic_year_id)
#  index_calendar_events_on_calendar_event_type_id  (calendar_event_type_id)
#  index_calendar_events_on_calendar_id             (calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#  fk_rails_...  (calendar_event_type_id => calendar_event_types.id)
#  fk_rails_...  (calendar_id => calendars.id)
#

class CalendarEvent < ApplicationRecord
  belongs_to :academic_year
  belongs_to :calendar, touch: true
  belongs_to :calendar_event_type

  scope :terms,             -> { joins(:calendar_event_type).merge(CalendarEventType.term) }
  scope :inset_days,        -> { joins(:calendar_event_type).merge(CalendarEventType.inset_day) }
  scope :holidays,          -> { joins(:calendar_event_type).merge(CalendarEventType.holiday) }
  scope :bank_holidays,     -> { joins(:calendar_event_type).merge(CalendarEventType.bank_holiday) }
  scope :outside_term_time, -> { joins(:calendar_event_type).merge(CalendarEventType.outside_term_time) }

  after_create :check_whether_child_needs_creating

  before_validation :update_academic_year

  validates :calendar, :calendar_event_type, :start_date, :end_date, presence: true

  validate :start_date_end_date_order, :no_overlaps

private

  def update_academic_year
    self.academic_year = calendar.academic_year_for(start_date) if start_date
  end

  def check_whether_child_needs_creating
    if calendar.calendars.any?
      calendar.calendars.each do |child_calendar|
        next if there_is_an_overlapping_child_event?(self, child_calendar)
        duplicate = self.dup
        duplicate.calendar = child_calendar
        duplicate.save!
      end
    end
  end

  def there_is_an_overlapping_child_event?(calendar_event, child_calendar)
    overlap_types = if calendar_event.calendar_event_type.term_time || calendar_event.calendar_event_type.holiday
                      (CalendarEventType.holiday + CalendarEventType.term)
                    else
                      [calendar_event.calendar_event_type]
                    end
    new_start_date = calendar_event.start_date
    new_end_date = calendar_event.end_date
    any_overlapping_before = any_overlapping_here?(overlap_types, child_calendar, new_start_date)
    any_overlapping_after = any_overlapping_here?(overlap_types, child_calendar, new_end_date)
    any_overlapping_before || any_overlapping_after
  end

  def any_overlapping_here?(overlap_types, child_calendar, date_to_check)
    child_calendar.calendar_events.where(calendar_event_type: overlap_types).where('start_date <= ? and end_date >= ?', date_to_check, date_to_check).any?
  end

  def start_date_end_date_order
    if (start_date && end_date) && (end_date < start_date)
      errors.add(:end_date, 'must be on or after the start date')
    end
  end

  def no_overlaps
    if (start_date && end_date && calendar_event_type) && (calendar_event_type.term_time || calendar_event_type.holiday)
      holiday_or_term_events = calendar.calendar_events.joins(:calendar_event_type).where(calendar_event_types: { id: (CalendarEventType.holiday + CalendarEventType.term) })
      if holiday_or_term_events.where.not(id: id).where('(start_date, end_date) OVERLAPS (?,?)', start_date, end_date).any?
        errors.add(:base, 'overlaps another event')
      end
    end
  end
end
