namespace :meters do
  desc 'Check which meters exist in the DCC'
  task check_for_dcc: :environment do |_t, _args|
    puts "#{DateTime.now.utc} check_for_dcc start"
    if ENV['ENVIRONMENT_IDENTIFIER'] == 'production'
      Meters::DccChecker.new(Meter.meters_to_check_against_dcc).perform
    else
      puts "#{Time.zone.now} Only running checks on production server"
    end
    puts "#{DateTime.now.utc} check_for_dcc end"
  end
end
