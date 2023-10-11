namespace :after_party do
  desc 'Deployment task: Remove gas intraday'
  task remove_gas_intraday: :environment do
    puts "Running deploy task 'remove_gas_intraday'"

    page = AdvicePage.find_by(key: :gas_intraday)&.destroy

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
