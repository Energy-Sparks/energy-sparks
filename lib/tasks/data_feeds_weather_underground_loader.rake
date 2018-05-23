namespace :data_feeds do
  desc 'Set up data feeds'
  task weather_underground_loader: [:environment] do
    DataFeeds::WeatherUndergroundLoader.new((Time.now - 2.days).beginning_of_day, Time.now.beginning_of_day).import
  end
end
