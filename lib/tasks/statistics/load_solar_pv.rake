namespace :statistics do
  desc "Get benchmarks for temperature data loads"
  task load_solar_pv: :environment do
    benchmarks = [] # Store all benchmark data for later output to csv
    SolarPvTuosArea.all.each do |solar_pv_tuos_area|
      benchmark_measure = Benchmark.measure {
        data = SolarPV.new('solar pv')
        DataFeeds::SolarPvTuosReading.where(area_id: solar_pv_tuos_area.id).pluck(:reading_date, :generation_mw_x48).each do |date, values|
          data.add(date, values.map(&:to_f))
        end
      }

      puts "#{solar_pv_tuos_area.title} (#{solar_pv_tuos_area.id}) #{benchmark_measure.real}"
      puts benchmark_measure

      benchmarks << [
        solar_pv_tuos_area.id,
        solar_pv_tuos_area.title,
        benchmark_measure.real
      ]
    end

    require 'csv'
    CSV.open("solar_pv_benchmarks.csv", "w") do |csv|
      csv << ['solar_pv_tuos_area_id', 'solar_pv_tuos_area_title', 'elapsed_real_time']
      benchmarks.each { |row| csv << row }
    end
  end
end
