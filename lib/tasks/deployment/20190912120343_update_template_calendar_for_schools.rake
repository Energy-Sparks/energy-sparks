namespace :after_party do
  desc 'Deployment task: update_template_calendar_for_schools'
  task update_template_calendar_for_schools: :environment do
    puts "Running deploy task 'update_template_calendar_for_schools'"

    # Put your task implementation HERE.
    School.all.each do |school|
      if school.calendar.based_on.present?
        school.update(template_calendar: school.calendar.based_on)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end