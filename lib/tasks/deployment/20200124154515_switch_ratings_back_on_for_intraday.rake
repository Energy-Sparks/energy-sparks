namespace :after_party do
  desc 'Deployment task: switch_ratings_back_on_for_intraday'
  task switch_ratings_back_on_for_intraday: :environment do
    puts "Running deploy task 'switch_ratings_back_on_for_intraday'"

    # Put your task implementation HERE.
    class_names = [
      'AdviceElectricityIntraday',
      'AdviceGasIntraday'
    ]
    AlertType.where(class_name: class_names).update_all(has_ratings: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
