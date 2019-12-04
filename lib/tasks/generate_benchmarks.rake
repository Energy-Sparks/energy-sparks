namespace :generate do
  desc "Validate readings"
  task benchmarks: :environment do
    GenerateBenchmarks.new(School.process_data).generate
  end
end
