namespace :statistics do
  desc "Get benchmarks for loading uk grid carbon intensity data"
  task load_uk_grid_carbon_intensity: :environment do
    uk_grid_carbon_intensity_data = GridCarbonIntensity.new
    benchmark_measure = Benchmark.measure {
      DataFeeds::CarbonIntensityReading.all.pluck(:reading_date, :carbon_intensity_x48).each do |date, values|
        uk_grid_carbon_intensity_data.add(date, values.map(&:to_f))
      end
      uk_grid_carbon_intensity_data
    }
    puts 'Benchmarks for loading uk grid carbon intensity data:'
    puts benchmark_measure.real
  end
end
