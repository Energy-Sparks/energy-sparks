namespace :data_feeds do
  desc 'Set up data feeds'
  task setup: [:environment] do

    Areas::WeatherUndergroundArea.delete_all
    DataFeeds::WeatherUnderground.delete_all

    wua = Areas::WeatherUndergroundArea.where(title: 'Bath').first_or_create
    pp wua.class
    DataFeeds::WeatherUnderground.where(title: 'Weather Underground', regional_area: wua).first_or_create
  end
end
