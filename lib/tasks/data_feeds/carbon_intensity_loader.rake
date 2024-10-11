require 'dashboard'

namespace :data_feeds do
  desc 'Load carbon intensity data'
  task :carbon_intensity_loader, [:start_date, :end_date] => :environment do |_t, args|
    puts "#{DateTime.now.utc} carbon_intensity_loader start"
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : Date.yesterday - 1
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    rake_process_carbon_feed(start_date, end_date)
    puts "#{DateTime.now.utc} carbon_intensity_loader end"
  end

  def rake_process_carbon_feed(start_date, end_date)
    data = DataFeeds::UKGridCarbonIntensityFeed.new.download(start_date, end_date)

    data.each do |reading_date, carbon_intensity_x48|
      next if carbon_intensity_x48.size != 48
      record = DataFeeds::CarbonIntensityReading.find_by(reading_date: reading_date)
      if record
        record.update(carbon_intensity_x48: carbon_intensity_x48)
      else
        DataFeeds::CarbonIntensityReading.create(reading_date: reading_date, carbon_intensity_x48: carbon_intensity_x48)
      end
    end
  end
end
