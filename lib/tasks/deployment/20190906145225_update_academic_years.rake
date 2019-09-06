namespace :after_party do
  desc 'Deployment task: update_academic_years'
  task update_academic_years: :environment do
    puts "Running deploy task 'update_academic_years'"

    # Put your task implementation HERE.
    ActiveRecord::Base.transaction do
      AcademicYear.all.each do |academic_year|
        calendar_area_name = academic_year.calendar_area.title
        calendar = Calendar.find_by(title: calendar_area_name)
        academic_year.update!(based_on_calendar_id: calendar.id)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end