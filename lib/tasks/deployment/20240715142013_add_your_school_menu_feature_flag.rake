namespace :after_party do
  desc 'Deployment task: add_your_school_menu_feature_flag'
  task add_your_school_menu_feature_flag: :environment do
    puts "Running deploy task 'add_your_school_menu_feature_flag'"

    Flipper.add(:your_school_menu)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
