namespace :after_party do
  desc 'Deployment task: update_red_kite_calendars'
  task update_red_kite_calendars: :environment do
    puts "Running deploy task 'update_red_kite_calendars'"

    yorkshire_calendar = Calendar.find(1095)
    red_kite = SchoolGroup.find('red-kite-learning-trust')

    if red_kite.present?
      red_kite.schools.each do |school|
        #update template, although this isn't used
        school.update!(template_calendar: yorkshire_calendar)
        if school.calendar.present?
          #change calendar to be based on yorkshire calendar
          school.calendar.update!(based_on: yorkshire_calendar)
          begin
            #reset the school calendar to match yorkshire
            CalendarResetService.new(school.calendar).reset
          rescue => e
            puts "Failed reseting #{school.name} calendar"
            puts e
            puts e.backtrace
          end
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
