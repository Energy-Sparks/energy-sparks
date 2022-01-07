namespace :data_feeds do
  desc 'Load solar pv data'
  task :solar_pv_tuos_loader, [:start_date, :end_date] => :environment do |_t, args|
    puts "#{DateTime.now.utc} solar_pv_tuos_loader start"

    start_date = args[:start_date].present? ? Date.parse(args[:start_date]) : Date.yesterday - 11
    end_date = args[:end_date].present? ? Date.parse(args[:end_date]) : Date.yesterday - 1

    DataFeeds::SolarPvTuosLoader.new(start_date, end_date).import
    puts "#{DateTime.now.utc} solar_pv_tuos_loader end"
  end
end
