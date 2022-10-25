namespace :alerts do
  desc 'Delete benchmark runs'
  task delete_benchmark_runs: [:environment] do
    puts "#{DateTime.now.utc} Delete benchmark runs start"
    ActiveRecord::Base.transaction do
      Alerts::DeleteBenchmarkRunService.new.delete!
    end
    puts "#{DateTime.now.utc} Delete benchmark runs end"
  end
end
