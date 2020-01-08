namespace :after_party do
  desc 'Deployment task: update_benchmark_counts'
  task update_benchmark_counts: :environment do
    puts "Running deploy task 'update_benchmark_counts'"

    # Put your task implementation HERE.
    BenchmarkResultSchoolGenerationRun.find_each { |brsgr| BenchmarkResultSchoolGenerationRun.reset_counters(brsgr.id, :benchmark_results) }
    BenchmarkResultSchoolGenerationRun.find_each { |brsgr| BenchmarkResultSchoolGenerationRun.reset_counters(brsgr.id, :benchmark_result_errors) }

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end