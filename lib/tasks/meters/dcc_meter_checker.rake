namespace :meters do
  desc 'Check which meters exist in the DCC'
  task :check_for_dcc => :environment do |_t, args|
    puts "#{DateTime.now.utc} check_for_dcc start"

    meters = Meter.active.main_meter.where.not(dcc_meter: true).where(dcc_checked_at: nil)
    Meters::DccChecker.new(meters).perform
    puts "#{DateTime.now.utc} check_for_dcc end"
  end
end
