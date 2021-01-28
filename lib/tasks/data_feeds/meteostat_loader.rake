namespace :data_feeds do
  desc 'Load dark meteostat data'
  task :meteostat_loader, [:start_date, :end_date] => :environment do |_t, args|
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : Date.yesterday - 8
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    loader = DataFeeds::MeteostatLoader.new(start_date, end_date)
    loader.import
    p "Imported #{loader.insert_count} records, Updated #{loader.update_count} records from #{loader.stations_processed} stations"
  end
end
