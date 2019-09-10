namespace :after_party do
  desc 'Deployment task: reset_highland_bank_holidays'
  task reset_highland_bank_holidays: :environment do
    puts "Running deploy task 'reset_highland_bank_holidays'"

    # Put your task implementation HERE.
    highland_calendar = Calendar.find_by(title: 'Highland')

    if highland_calendar
      raise ArgumentError.new("Missing bank holidays for Highlands calendar") unless highland_calendar.bank_holidays.any?
      raise ArgumentError.new("Missing parent calendar for Highlands calendar") unless highland_calendar.based_on

      ActiveRecord::Base.transaction do

        highland_calendar.bank_holidays.delete_all

        calendar_event_type = CalendarEventType.bank_holiday.first

        highland_calendar.based_on.bank_holidays.each do |bank_holiday|
          highland_calendar.bank_holidays.where(
            title: bank_holiday.title,
            calendar_event_type: calendar_event_type,
            start_date: bank_holiday.start_date,
            end_date: bank_holiday.end_date).first_or_create!
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
