namespace :after_party do
  desc 'Deployment task: update_calendar_event_types'
  task update_calendar_event_types: :environment do
    puts "Running deploy task 'update_calendar_event_types'"

    ActiveRecord::Base.transaction do

      # Put your task implementation HERE.
      CalendarEventType.term.each { |term| term.update!(analytics_event_type: :term_time)}
      CalendarEventType.where(bank_holiday: true).each { |bank_holiday| bank_holiday.update!(analytics_event_type: :bank_holiday)}
      CalendarEventType.holiday.each { |holiday| holiday.update!(analytics_event_type: :school_holiday)}

      CalendarEventType.inset_day.each do |inset_day|
        if inset_day.school_occupied
          inset_day.update!(analytics_event_type: :inset_day_in_school)
        else
          inset_day.update!(analytics_event_type: :inset_day_out_of_school)
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end