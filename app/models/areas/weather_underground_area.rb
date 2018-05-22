class Areas::WeatherUndergroundArea < Area
  has_many :data_feeds, as: :regional_area#, class_name: 'WeatherUndergroundArea'
end
