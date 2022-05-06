namespace :calendars do
  desc 'Set calendar event parents'
  task set_calendar_event_parents: [:environment] do
    pp "Setting calendar event parents"
    Calendar.where.not(based_on: nil).each do |calendar|
      CalendarInitService.new(calendar).call
    end
    pp "Finished"
  end
end
