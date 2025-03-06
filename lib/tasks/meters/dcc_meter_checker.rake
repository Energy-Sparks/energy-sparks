# frozen_string_literal: true

namespace :meters do
  desc 'Check which meters exist in the DCC'
  task check_for_dcc: :environment do |_t, _args|
    puts "#{DateTime.now.utc} check_for_dcc start"
    if ENV['ENVIRONMENT_IDENTIFIER'] == 'production'
      meters = Meter.meters_to_check_against_dcc
      meters = Meter.dcc_meter_smets2 if ENV['DCC_METER_CHECKER_ALL_SMETS2']
      Meters::DccChecker.new(meters).perform
    else
      puts "#{Time.zone.now} Only running checks on production server"
    end
    puts "#{DateTime.now.utc} check_for_dcc end"
  end
end
