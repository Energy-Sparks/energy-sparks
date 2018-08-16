namespace :data_feeds do
  desc 'Set up data feeds'
  task :solar_pv_tuos_loader, [:start_date, :end_date] => :environment do |_t, args|
    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : Date.yesterday - 1
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday

    old_readings = DataFeedReading.where(feed_type: :solar_pv).where('at >= ? and at <= ?', start_date.beginning_of_day, end_date.end_of_day)
    p "Clear out readings for #{start_date} - #{end_date} - records #{old_readings.count}"
    old_readings.delete_all

    p "Now import"
    DataFeeds::SolarPvTuosLoader.new(start_date, end_date).import
    new_readings = DataFeedReading.where(feed_type: :solar_pv).where('at >= ? and at <= ?', start_date, end_date)
    p "New readings for #{start_date} - #{end_date} - records #{new_readings.count}"
  end
end
