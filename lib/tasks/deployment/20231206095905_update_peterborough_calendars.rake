namespace :after_party do
  desc 'Deployment task: update_peterborough_calendars'
  task update_peterborough_calendars: :environment do
    puts "Running deploy task 'update_peterborough_calendars'"

    #Schools have been setup using wrong calendar, so update all to match
    peterborough_calendar = Calendar.find(892)
    peterborough = SchoolGroup.find('peterborough-diocese-education-trust')

    if peterborough.present?
      peterborough.schools.each do |school|
        #update template
        school.update!(template_calendar: peterborough_calendar)
        if school.calendar.present?
          #change calendar to be based on peterborough calendar
          school.calendar.update!(based_on: peterborough_calendar)
          begin
            #reset the school calendar to match peterborough
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
