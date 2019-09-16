namespace :after_party do
  desc 'Deployment task: update_calendar_ids_on_new_columns'
  task update_calendar_ids_on_new_columns: :environment do
    puts "Running deploy task 'update_calendar_ids_on_new_columns'"

    # Put your task implementation HERE.
    ActiveRecord::Base.transaction do

      SchoolGroup.all.each do |school_group|
        next unless school_group.default_calendar_area
        calendar = school_group.default_calendar_area.calendars.where(template: true).first
        school_group.update!(default_template_calendar_id: calendar.id) if calendar.present?
      end

      SchoolOnboarding.all.each do |school_onboarding|
        calendar_area = school_onboarding.calendar_area || school_onboarding.school_group.default_calendar_area

        calendar = calendar_area.calendars.where(template: true).first
        school_onboarding.update!(template_calendar_id: calendar.id) if calendar.present?
      end

      Scoreboard.all.each do |scoreboard|
        calendar = scoreboard.calendar_area.calendars.where(template: true).first
        scoreboard.update!(academic_year_calendar_id: calendar.id) if calendar.present?
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
