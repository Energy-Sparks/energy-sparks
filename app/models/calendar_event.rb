# == Schema Information
#
# Table name: calendar_events
#
#  academic_year_id       :bigint(8)        not null
#  based_on_id            :bigint(8)
#  calendar_event_type_id :bigint(8)        not null
#  calendar_id            :bigint(8)        not null
#  created_at             :datetime         not null
#  description            :text
#  end_date               :date             not null
#  id                     :bigint(8)        not null, primary key
#  start_date             :date             not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_calendar_events_on_academic_year_id        (academic_year_id)
#  index_calendar_events_on_calendar_event_type_id  (calendar_event_type_id)
#  index_calendar_events_on_calendar_id             (calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id) ON DELETE => restrict
#  fk_rails_...  (calendar_event_type_id => calendar_event_types.id) ON DELETE => restrict
#  fk_rails_...  (calendar_id => calendars.id) ON DELETE => cascade
#

class CalendarEvent < ApplicationRecord
  belongs_to :academic_year
  belongs_to :calendar, touch: true
  belongs_to :calendar_event_type

  belongs_to  :based_on, class_name: 'CalendarEvent', optional: true
  has_many    :calendar_events, class_name: 'CalendarEvent', foreign_key: :based_on_id

  scope :terms,             -> { joins(:calendar_event_type).merge(CalendarEventType.term) }
  scope :inset_days,        -> { joins(:calendar_event_type).merge(CalendarEventType.inset_day) }
  scope :holidays,          -> { joins(:calendar_event_type).merge(CalendarEventType.holiday) }
  scope :bank_holidays,     -> { joins(:calendar_event_type).merge(CalendarEventType.bank_holiday) }
  scope :outside_term_time, -> { joins(:calendar_event_type).merge(CalendarEventType.outside_term_time) }

  scope :by_end_date,       -> { order(end_date: :asc) }
  before_validation :update_academic_year

  validates :calendar, :calendar_event_type, :start_date, :end_date, presence: true
  validate :start_date_end_date_order, :no_overlaps, :calendar_event_type_is_valid

  def display_title
    "#{calendar_event_type.display_title} #{description} : #{start_date} to #{end_date}"
  end

  private

  def update_academic_year
    self.academic_year = calendar.academic_year_for(start_date) if start_date
  end

  def start_date_end_date_order
    return unless start_date && end_date && (end_date < start_date)

    errors.add(:end_date, 'must be on or after the start date')
  end

  def no_overlaps
    return unless start_date && end_date && calendar_event_type

    overlap_types = if calendar_event_type.term_time || calendar_event_type.holiday
                      (CalendarEventType.holiday + CalendarEventType.term)
                    else
                      [calendar_event_type]
                    end
    events_to_check = calendar.calendar_events.where(calendar_event_type: overlap_types)
    if events_to_check.where.not(id: id).where('(start_date, end_date) OVERLAPS (?,?)', start_date, end_date).any?
      errors.add(:base, 'overlaps another term or holiday event')
    end
  end

  def calendar_event_type_is_valid
    return unless calendar.national? && !calendar_event_type.bank_holiday?

    errors.add(:base, 'only Bank Holidays can be created on National calendars')
  end
end
