namespace :data_feeds do
  desc 'Set up data feeds'
  task solar_pv_tuos_back_fill: :environment do

    MINIMUM_READINGS_PER_YEAR = 365
    BACK_FILL_YEARS = 4

    abort("API Key has not been set") unless ENV['ENERGYSPARKSDARKSKYHISTORICAPIKEY']

    SolarPvTuosArea.all.each do |solar_pv_tuos_area|
      next if solar_pv_tuos_area.solar_pv_tuos_readings.count > MINIMUM_READINGS_PER_YEAR * BACK_FILL_YEARS

      BACK_FILL_YEARS.times.each do |year_number|
        # End date
        # Year 0 - Date Today
        # Year 1 - Date Today - 1 year
        # Year 2 - Date Today - 2 year
        # Year 3 - Date Today - 3 year
        end_date = Date.yesterday - (year_number * MINIMUM_READINGS_PER_YEAR)
        start_date = end_date - MINIMUM_READINGS_PER_YEAR.days

        p "Running #{solar_pv_tuos_area.title} for #{start_date} - #{end_date}"

        DataFeeds::SolarPvTuosV2Loader.new(start_date, end_date).import_area(solar_pv_tuos_area)
      end
    end
  end
end
