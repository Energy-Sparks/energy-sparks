namespace :data_feeds do
  desc 'Set up data feeds'
  task weather_underground_loader: [:environment] do
    DataFeeds::WeatherUndergroundLoader.new(Date.new(2018, 5, 20), Date.new(2018, 5, 21)).import
  #DataFeeds::WeatherUndergroundLoader.new.import
  end
end
