namespace :after_party do
  desc 'Deployment task: update_calendars_with_types'
  task update_calendars_with_types: :environment do
    puts "Running deploy task 'update_calendars_with_types'"

    # Put your task implementation HERE.
    calendars_to_delete = Calendar.unscoped.where(deleted: true)
    calendars_to_delete.each do |calendar|
      calendar.calendar_events.delete_all
      calendar.delete
    end

    Calendar.where(template: true, based_on_id: nil).update(bank_holiday_calendar: true)
    Calendar.where(template: true).where.not(based_on_id: nil).update(term_calendar: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end