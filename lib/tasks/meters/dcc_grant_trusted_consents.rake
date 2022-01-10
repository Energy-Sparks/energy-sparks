namespace :meters do
  desc 'Grant trusted consents in the DCC'
  task :dcc_grant_trusted_consents => :environment do |_t, args|
    puts "#{DateTime.now.utc} dcc_grant_trusted_consents start"

    meters = Meter.awaiting_trusted_consent
    Meters::DccGrantTrustedConsents.new(meters).perform
    puts "#{DateTime.now.utc} dcc_grant_trusted_consents end"
  end
end
