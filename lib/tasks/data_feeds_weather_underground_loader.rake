namespace :data_feeds do
  desc 'Set up data feeds'
  task weather_underground_loader: [:environment] do
 #   DataFeeds::WeatherUndergroundLoader.new((Time.zone.now - 2.days).beginning_of_day, Time.zone.now.beginning_of_day - 1.days).import
  DataFeeds::WeatherUndergroundLoader.new.import
  end
end
