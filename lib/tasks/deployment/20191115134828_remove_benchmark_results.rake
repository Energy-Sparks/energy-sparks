namespace :after_party do
  desc 'Deployment task: remove_benchmark_results'
  task remove_benchmark_results: :environment do
    puts "Running deploy task 'remove_benchmark_results'"

    # Put your task implementation HERE.
    BenchmarkResult.delete_all!

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
