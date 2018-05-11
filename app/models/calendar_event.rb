# == Schema Information
#
# Table name: calendar_events
#
#  calendar_event_type_id :bigint(8)
#  calendar_id            :bigint(8)
#  end_date               :date
#  id                     :bigint(8)        not null, primary key
#  start_date             :date
#
# Indexes
#
#  index_calendar_events_on_calendar_event_type_id  (calendar_event_type_id)
#  index_calendar_events_on_calendar_id             (calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (calendar_event_type_id => calendar_event_types.id)
#  fk_rails_...  (calendar_id => calendars.id)
#

class CalendarEvent < ApplicationRecord
  belongs_to :calendar
  belongs_to :calendar_event_type
  
end
