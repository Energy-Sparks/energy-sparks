namespace :after_party do
  desc 'Deployment task: tgp_gas_feeds'
  task tgp_gas_feeds: :environment do
    puts "Running deploy task 'tgp_gas_feeds'"

    config = {}
    config['description'] = "TGP Gas Feed Configuration"
    config['identifier'] = 'tgp-gas'
    config['date_format'] = "%d/%m/%Y"
    config['mpan_mprn_field'] = 'MPR'
    config['reading_date_field'] = 'ReadDate'
    config['meter_description_field'] = 'Site'
    config['total_field'] = 'ProfileDateConsumption'
    config['units_field'] = 'ReportingUnit'
    config['reading_fields'] = 'H0030,H0100,H0130,H0200,H0230,H0300,H0330,H0400,H0430,H0500,H0530,H0600,H0630,H0700,H0730,H0800,H0830,H0900,H0930,H1000,H1030,H1100,H1130,H1200,H1230,H1300,H1330,H1400,H1430,H1500,H1530,H1600,H1630,H1700,H1730,H1800,H1830,H1900,H1930,H2000,H2030,H2100,H2130,H2200,H2230,H2300,H2330,H2400'.split(',')
    config['header_example'] = 'ConsumerName,MPR,MPRAlias,Site,AMRSchedule,ReadDate,Reading,ConsumptionProfileDate,ProfileDateConsumption,H0030,H0100,H0130,H0200,H0230,H0300,H0330,H0400,H0430,H0500,H0530,H0600,H0630,H0700,H0730,H0800,H0830,H0900,H0930,H1000,H1030,H1100,H1130,H1200,H1230,H1300,H1330,H1400,H1430,H1500,H1530,H1600,H1630,H1700,H1730,H1800,H1830,H1900,H1930,H2000,H2030,H2100,H2130,H2200,H2230,H2300,H2330,H2400,ReportingUnit'
    config['number_of_header_rows'] = 1

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
