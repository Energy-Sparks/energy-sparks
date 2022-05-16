namespace :alerts do
  desc 'Delete benchmark runs'
  task delete_benchmark_runs: [:environment] do
    puts "#{DateTime.now.utc} Delete benchmark runs start"
    Alerts::DeleteBenchmarkRunService.new.delete!
    puts "#{DateTime.now.utc} Delete benchmark runs end"
  end
end
