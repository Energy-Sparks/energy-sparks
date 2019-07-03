namespace :after_party do
  desc 'Deployment task: update_academic_years_for_events'
  task update_academic_years_for_events: :environment do
    puts "Running deploy task 'update_academic_years_for_events'"

    CalendarEvent.transaction do
      CalendarEvent.where(academic_year: nil).all.each do |calendar_event|
        academic_year = AcademicYear.for_date(calendar_event.start_date)
        puts "Updating academic year for #{calendar_event.start_date}-#{calendar_event.end_date} to #{academic_year.title}"
        calendar_event.update!(academic_year: academic_year)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
