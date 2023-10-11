namespace :calendars do
  desc 'Set calendar event parents'
  task set_calendar_event_parents: [:environment] do
    calendars = Calendar.where.not(based_on: nil)
    pp "Setting calendar event parents for #{calendars.count} calendars"

    calendars.each do |calendar|
      pp "Initialising calendar #{calendar.title}"
      service = CalendarInitService.new(calendar)
      service.call
      service.messages.each { |message| pp message }
    end
    pp 'Finished'
  end
end
