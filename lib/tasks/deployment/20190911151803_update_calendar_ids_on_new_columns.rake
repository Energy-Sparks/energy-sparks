namespace :after_party do
  desc 'Deployment task: update_calendar_ids_on_new_columns'
  task update_calendar_ids_on_new_columns: :environment do
    puts "Running deploy task 'update_calendar_ids_on_new_columns'"

    # Put your task implementation HERE.
    ActiveRecord::Base.transaction do

      SchoolGroup.all.each do |school_group|
        next unless school_group.default_calendar_area
        calendar_area_name = school_group.default_calendar_area.title
        calendar = Calendar.where("title like ?", "%#{calendar_area_name}%").first
        school_group.update!(default_template_calendar_id: calendar.id)
      end

      highlands_calendar = Calendar.find_by(title: 'Highland')

      if highlands_calendar.present? && (highlands_school_group = SchoolGroup.find_by(name: 'Highlands'))
        highlands_school_group.update(default_template_calendar_id: highlands_calendar.id)
      end

      SchoolOnboarding.all.each do |school_onboarding|
        calendar_area_name = school_onboarding.calendar_area.title
        calendar = Calendar.where("title like ?", "%#{calendar_area_name}%").first

        school_onboarding.update!(template_calendar_id: calendar.id)
      end

      Scoreboard.all.each do |scoreboard|
        calendar_area_name = scoreboard.calendar_area.title
        calendar = Calendar.where("title like ?", "%#{calendar_area_name}%").first

        scoreboard.update!(academic_year_calendar_id: calendar.id)
      end
    end



    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end