namespace :after_party do
  desc 'Deployment task: Migrate benchmark results to JSON'
  task migrate_benchmark_result_data: :environment do
    puts "Running deploy task 'migrate_benchmark_result_data'"

    BenchmarkResultGenerationRun.latest.benchmark_results.each do |br|
      br.results = br.data
      br.save!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
