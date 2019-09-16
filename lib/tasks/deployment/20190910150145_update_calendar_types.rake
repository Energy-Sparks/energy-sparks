namespace :after_party do
  desc 'Deployment task: update_calendar_types'
  task update_calendar_types: :environment do
    puts "Running deploy task 'update_calendar_types'"

    # Put your task implementation HERE.
    ActiveRecord::Base.transaction do

      calendars_to_delete = Calendar.unscoped.where(deleted: true)
      calendars_to_delete.each do |calendar|
        calendar.calendar_events.delete_all
        calendar.delete
      end

      Calendar.where(template: true, based_on_id: nil).update(calendar_type: :national)
      Calendar.where(template: true).where.not(based_on_id: nil).update(calendar_type: :regional)
      Calendar.where(template: false).where.not(based_on_id: nil).update(calendar_type: :school)

    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end