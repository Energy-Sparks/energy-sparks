namespace :after_party do
  desc 'Deployment task: add_bank_holidays'
  task add_bank_holidays_to_new_calendars: :environment do
    puts "Running deploy task 'add_bank_holidays_to_new_calendars'"

    # Put your task implementation HERE.
    Loader::BankHolidays.load!("etc/bank_holidays/bank-holidays.json")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
