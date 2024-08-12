namespace :after_party do
  desc 'Deployment task: update_activity_maximum_frequency'
  task update_activity_maximum_frequency: :environment do
    puts "Running deploy task 'update_activity_maximum_frequency'"

    ActivityType.where(id: [9]).update_all(maximum_frequency: 1)
    ActivityType.where(id: [84, 91, 113, 145, 33, 34, 38, 39, 56, 57, 74, 75, 76, 81, 88, 90, 92, 110, 133, 158, 180])
                .update_all(maximum_frequency: 2)
    ActivityType.where(id: [116, 117, 118, 119, 147, 181, 182, 10, 11, 12, 52, 63, 73, 78, 159, 166, 170, 173, 178, 185,
                            186, 15, 16, 17, 18, 19, 20, 21, 23, 24, 26, 27, 30, 31, 37, 53, 61, 79, 128, 130, 134, 142,
                            148, 156, 169, 174, 177, 13, 43, 44, 50, 60, 67, 68, 144, 160, 176])
                .update_all(maximum_frequency: 6)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
