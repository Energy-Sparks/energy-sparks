namespace :after_party do
  desc 'Deployment task: move_highland_calendar_to_scotland_calendar_area'
  task move_highland_calendar_to_scotland_calendar_area: :environment do
    puts "Running deploy task 'move_highland_calendar_to_scotland_calendar_area'"

    scotland = CalendarArea.where(title: 'Scotland').first_or_create!
    AcademicYearFactory.new(scotland, start_date: '01-08', end_date: '31-07').create

    highlands_area = CalendarArea.where(title: 'Highland').first

    if highlands_area
      highlands_area.update!(parent_area: scotland)
      highlands_area.calendars.each do |calendar|
        calendar.calendar_events.each do |calendar_event|
          academic_year = calendar_event.calendar.academic_year_for(calendar_event.start_date)
          calendar_event.update!(academic_year: academic_year)
        end
      end
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
