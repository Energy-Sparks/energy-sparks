namespace :data_feeds do
  desc 'Set up data feeds'
  task setup: [:environment] do
    WeatherUndergroundArea.delete_all
    DataFeeds::WeatherUnderground.delete_all

    wua = WeatherUndergroundArea.where(title: 'Bath').first_or_create
    pp wua.class
    DataFeeds::WeatherUnderground.where(title: 'Weather Underground', area: wua).first_or_create
  end
end
