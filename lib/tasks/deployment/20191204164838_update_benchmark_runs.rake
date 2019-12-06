namespace :after_party do
  desc 'Deployment task: update_benchmark_runs'
  task update_benchmark_runs: :environment do
    puts "Running deploy task 'update_benchmark_runs'"

    # Put your task implementation HERE.
    benchmark_count_hash = BenchmarkResultSchoolGenerationRun.where(benchmark_result_generation_run: nil).group("date_trunc('hour', created_at)").count

    benchmark_count_hash.each do |trunc_date, _number_of_records|
      benchmark_result_generation_run = BenchmarkResultGenerationRun.create(created_at: trunc_date)
      BenchmarkResultSchoolGenerationRun.where("date_trunc('hour', created_at) = ?", trunc_date).update_all(benchmark_result_generation_run_id: benchmark_result_generation_run.id)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
