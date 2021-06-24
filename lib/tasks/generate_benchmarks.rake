namespace :generate do
  desc "Generate benchmarks"
  task benchmarks: :environment do
    puts "#{DateTime.now.utc} Generate benchmarks start"
    GenerateBenchmarks.new(School.process_data).generate
    puts "#{DateTime.now.utc} Generate benchmarks end"
  end
end
