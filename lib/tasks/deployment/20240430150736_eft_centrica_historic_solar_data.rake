namespace :after_party do
  desc 'Deployment task: eft_centrica_historic_solar_data'
  task eft_centrica_historic_solar_data: :environment do
    puts "Running deploy task 'eft_centrica_historic_solar_data'"

    config = {}
    config['description'] = "EfT Centrica Historic Solar"
    config['identifier'] = 'eft-centrica-solar'
    config['notes'] = "Format for loading historical solar data for Eft Centrica. Uses serial numbers"
    config['number_of_header_rows'] = 1
    config['date_format'] = "%Y-%m-%d 00:00:00"

    config['header_example'] = "mpan,meter,time,total,reading0000,reading0030,reading0100,reading0130,reading0200,reading0230,reading0300,reading0330,reading0400,reading0430,reading0500,reading0530,reading0600,reading0630,
reading0700,reading0730,reading0800,reading0830,reading0900,reading0930,reading1000,reading1030,reading1100,reading1130,reading1200,reading1230,reading1300,reading1330,reading1400,reading143
0,reading1500,reading1530,reading1600,reading1630,reading1700,reading1730,reading1800,reading1830,reading1900,reading1930,reading2000,reading2030,reading2100,reading2130,reading2200,reading2
230,reading2300,reading2330"
    config['mpan_mprn_field'] = '' # must not be null, but wont be used
    config['msn_field'] = 'meter'
    config['lookup_by_serial_number'] = true
    config['reading_date_field'] = 'time'
    config['reading_fields'] = "reading0000,reading0030,reading0100,reading0130,reading0200,reading0230,reading0300,reading0330,reading0400,reading0430,reading0500,reading0530,reading0600,reading0630,
reading0700,reading0730,reading0800,reading0830,reading0900,reading0930,reading1000,reading1030,reading1100,reading1130,reading1200,reading1230,reading1300,reading1330,reading1400,reading143
0,reading1500,reading1530,reading1600,reading1630,reading1700,reading1730,reading1800,reading1830,reading1900,reading1930,reading2000,reading2030,reading2100,reading2130,reading2200,reading2
230,reading2300,reading2330".split(",")

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
