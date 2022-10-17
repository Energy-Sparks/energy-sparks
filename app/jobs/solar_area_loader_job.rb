class SolarAreaLoaderJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(area)
    start_date = Date.yesterday - 30.days
    DataFeeds::SolarPvTuosLoader.new(start_date).import_area(area)
  end
end
