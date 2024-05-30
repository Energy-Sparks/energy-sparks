class SolarAreaLoaderJob < ApplicationJob
  queue_as :default

  def perform(area)
    start_date = Date.yesterday - 2.years
    DataFeeds::SolarPvTuosLoader.new(start_date).import_area(area)
  end
end
