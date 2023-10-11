namespace :after_party do
  desc 'Deployment task: change_boiler_control'
  task change_boiler_control: :environment do
    puts "Running deploy task 'change_boiler_control'"

    advice_page = AdvicePage.find_by(key: :boiler_control)
    advice_page.update!(key: :heating_control)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
