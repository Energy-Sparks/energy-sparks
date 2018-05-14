# json.extract! calendar, :id, :name, :created_at, :updated_at
# json.url calendar_url(calendar, format: :json)

json.calendar_events @calendar.calendar_events do |event|
  json.id event.id
  json.name event.calendar_event_type.description
  json.startDate event.start_date
  json.endDate event.end_date
end
