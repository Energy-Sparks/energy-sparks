namespace :data_feeds do
  desc 'Backfill solar pv data'
  task solar_pv_tuos_back_fill: :environment do
    puts "#{DateTime.now.utc} solar_pv_tuos_back_fill start"

    MINIMUM_READINGS_PER_YEAR = 365

    SolarPvTuosArea.by_title.each do |solar_pv_tuos_area|

      unless solar_pv_tuos_area.has_sufficient_readings?(Date.yesterday, MINIMUM_READINGS_PER_YEAR)

        solar_pv_tuos_area.back_fill_years.times.each do |year_number|
          # End date
          # Year 0 - Date Today
          # Year 1 - Date Today - 1 year
          # Year 2 - Date Today - 2 year
          # Year 3 - Date Today - 3 year
          end_date = Date.yesterday - (year_number * MINIMUM_READINGS_PER_YEAR)
          start_date = end_date - MINIMUM_READINGS_PER_YEAR.days

          p "Running #{solar_pv_tuos_area.title} for #{start_date} - #{end_date}"

          DataFeeds::SolarPvTuosLoader.new(start_date, end_date).import_area(solar_pv_tuos_area)

          break if solar_pv_tuos_area.has_sufficient_readings?(Date.yesterday, MINIMUM_READINGS_PER_YEAR)

        end
      end
    end

    puts "#{DateTime.now.utc} solar_pv_tuos_back_fill end"

  end
end
