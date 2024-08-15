namespace :after_party do
  desc 'Deployment task: update_maximum_frequency_2024'
  task update_maximum_frequency_2024: :environment do
    puts "Running deploy task 'update_maximum_frequency_2024'"

    ActivityType.where(id: [9]).update_all(maximum_frequency: 1)
    ActivityType.where(id: [84, 91, 113, 145, 33, 34, 38, 39, 56, 57, 74, 75, 76, 81, 88, 90, 92, 110, 133, 158, 180])
                .update_all(maximum_frequency: 2)
    ActivityType.where(id: [116, 117, 118, 119, 147, 181, 182, 10, 11, 12, 52, 63, 73, 78, 159, 166, 170, 173, 178, 185,
                            186, 15, 16, 17, 18, 19, 20, 21, 23, 24, 26, 27, 30, 31, 37, 53, 61, 79, 128, 130, 134, 142,
                            148, 156, 169, 174, 177, 13, 43, 44, 50, 60, 67, 68, 144, 160, 176])
                .update_all(maximum_frequency: 6)

    InterventionType.where(id: [1, 2, 3, 4, 5, 20, 21, 22, 23, 72, 6, 7, 8, 9, 13, 26, 27, 29, 31, 32, 64, 65, 45, 47,
                                49, 50, 51, 54, 55, 57, 58, 59, 60, 61, 62, 14, 15, 33, 34, 35, 36, 37, 38, 39, 56, 67,
                                69])
                    .update_all(maximum_frequency: 2)
    InterventionType.where(id: [10, 11, 12, 28, 30, 40, 41, 42, 43, 46, 48, 52, 53, 70, 71])
                    .update_all(maximum_frequency: 6)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
