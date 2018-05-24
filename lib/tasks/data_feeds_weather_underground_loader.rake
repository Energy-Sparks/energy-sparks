namespace :data_feeds do
  desc 'Set up data feeds'
  task :weather_underground_loader, [:start_date, :end_date] => :environment do |t, args|

    start_date = Date.parse args[:start_date] ||= Date.yesterday - 1
    end_date = Date.parse args[:end_date] ||= Date.yesterday

    old_readings = DataFeedReading.where(feed_type: [:solar_insolence, :temperature]).where('at >= ? and at <= ?', start_date, end_date)
    p "Clear out readings for #{start_date} - #{end_date} - records #{old_readings.count}"
    old_readings.delete_all

    p "Now import"
    DataFeeds::WeatherUndergroundLoader.new(start_date, end_date).import
    new_readings = DataFeedReading.where(feed_type: [:solar_insolence, :temperature]).where('at >= ? and at <= ?', start_date, end_date)
    p "New readings for #{start_date} - #{end_date} - records #{new_readings.count}"
  end
end


task :my_task, [:first_param, :second_param] => :environment do |t, args|
  puts args[:first_param]
  puts args[:second_param]
end