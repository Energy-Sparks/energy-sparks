namespace :after_party do
  desc 'Deployment task: flipper_school_academic_year_comparisons'
  task flipper_school_academic_year_comparisons: :environment do
    puts "Running deploy task 'flipper_school_academic_year_comparisons'"

    Flipper.add(:school_academic_year_comparisons)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
