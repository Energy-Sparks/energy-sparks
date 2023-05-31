namespace :meters do
  desc 'Check which meters exist in the DCC'
  task :check_for_dcc => :environment do |_t, args|
    puts "#{DateTime.now.utc} check_for_dcc start"
    Meters::DccChecker.new(Meter.meters_to_check_against_dcc).perform
    puts "#{DateTime.now.utc} check_for_dcc end"
  end
end
