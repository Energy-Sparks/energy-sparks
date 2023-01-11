namespace :after_party do
  desc 'Deployment task: create_advice_page_baseload'
  task create_advice_page_baseload: :environment do
    puts "Running deploy task 'create_advice_page_baseload'"

    AdvicePage.create!(key: 'baseload') unless AdvicePage.find_by_key('baseload')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
