namespace :after_party do
  desc 'Deployment task: 5525_update_the_calendar_for_the_gorse_academies'
  task '5525_update_the_calendar_for_the_gorse_academies': :environment do
    puts "Running deploy task '5525_update_the_calendar_for_the_gorse_academies'"

    calendar = Calendar.find_by!(title: 'Leeds')
    SchoolGroup.find_by!(slug: 'the-gorse-academies-trust').schools.each do |school|
      school.update!(template_calendar: calendar)
      next if school.calendar.blank? || school.calendar.based_on == calendar

      school.calendar.update!(based_on: calendar)
      begin
        CalendarResetService.new(school.calendar).reset
      rescue StandardError => e
        puts "Failed reseting #{school.name} calendar"
        puts e
        puts e.backtrace
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
