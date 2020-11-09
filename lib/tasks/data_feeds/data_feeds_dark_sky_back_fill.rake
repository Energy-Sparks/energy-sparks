namespace :data_feeds do
  desc 'Set up data feeds'
  task dark_sky_back_fill: :environment do

    MINIMUM_READINGS_PER_YEAR = 365

    DarkSkyArea.all.each do |dark_sky_area|

      back_fill_years = dark_sky_area.back_fill_years

      next if dark_sky_area.dark_sky_temperature_readings.since(back_fill_years.years.ago).count > MINIMUM_READINGS_PER_YEAR * back_fill_years

      back_fill_years.times.each do |year_number|
        # End date
        # Year 0 - Date Today
        # Year 1 - Date Today - 1 year
        # Year 2 - Date Today - 2 year
        # Year 3 - Date Today - 3 year
        end_date = Date.yesterday - (year_number * MINIMUM_READINGS_PER_YEAR)
        start_date = end_date - MINIMUM_READINGS_PER_YEAR.days

        p "Running #{dark_sky_area.title} for #{start_date} - #{end_date}"

        DataFeeds::DarkSkyTemperatureLoader.new(start_date, end_date).import_area(dark_sky_area)
      end
    end
  end
end
