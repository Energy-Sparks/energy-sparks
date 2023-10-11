namespace :data_feeds do
  desc 'Reload Solar PV data from Sheffield'
  task solar_pv_reload: :environment do
    puts "#{DateTime.now.utc} solar_pv_reload start"

    SolarPvTuosArea.active.by_title.each do |solar_pv_tuos_area|
      puts "Starting reload for #{solar_pv_tuos_area.title}"
      # find the earliest reading
      earliest_reading_date = solar_pv_tuos_area.solar_pv_tuos_readings.minimum(:reading_date)
      start_date = earliest_reading_date.beginning_of_year

      # reload the readings, one year at a time
      while start_date.year != Date.today.year
        end_date = start_date.end_of_year
        puts "Running loader for #{start_date} - #{end_date}"
        DataFeeds::SolarPvTuosLoader.new(start_date, end_date).import_area(solar_pv_tuos_area)
        start_date = start_date.next_year
      end
      end_date = Date.yesterday
      puts "Running loader for #{start_date} - #{end_date}"
      DataFeeds::SolarPvTuosLoader.new(start_date, end_date).import_area(solar_pv_tuos_area)
    end
    puts "#{DateTime.now.utc} solar_pv_reload end"
  end
end
