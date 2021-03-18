namespace :meters do
  desc 'Check which meters exist in the DCC'
  task :check_for_dcc => :environment do |_t, args|
    meters = Meter.where.not(dcc_meter: true).where(dcc_checked_at: nil)
    Meters::DccChecker.new(meters).perform
  end
end
