# == Schema Information
#
# Table name: calendar_events
#
#  academic_year_id       :bigint(8)
#  calendar_event_type_id :bigint(8)
#  calendar_id            :bigint(8)
#  description            :text
#  end_date               :date
#  id                     :bigint(8)        not null, primary key
#  start_date             :date
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
  belongs_to :calendar
  belongs_to :calendar_event_type

  scope :terms,       -> { joins(:calendar_event_type).merge(CalendarEventType.term) }
  scope :inset_days,  -> { joins(:calendar_event_type).merge(CalendarEventType.inset_day) }
  scope :holidays,    -> { joins(:calendar_event_type).merge(CalendarEventType.holiday) }

  # def in_academic_year_starting?(start_year_of_academic_year)
  #   return false if calendar_event_type.term_time == false
  #   if start_date.month > 8 # Autumn Term
  #     start_date.year == start_year_of_academic_year
  #   else
  #     start_date.year == start_year_of_academic_year + 1
  #   end
  # end
end
