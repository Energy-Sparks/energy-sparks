# json.extract! calendar, :id, :name, :created_at, :updated_at
# json.url calendar_url(calendar, format: :json)

json.calendar_events @calendar.calendar_events.order(calendar_event_type_id: :asc) do |event|
  json.id event.id
  json.calendarEventTypeId event.calendar_event_type.id
  json.name "#{event.calendar_event_type.description}"
  json.color Colours.hex(event.calendar_event_type.analytics_event_type.to_sym)
  json.startDate event.start_date
  json.endDate event.end_date
  json.basedOn !event.based_on.nil?
end
