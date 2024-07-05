namespace :after_party do
  desc 'Deployment task: energy_assets_serial_num'
  task energy_assets_serial_num: :environment do
    puts "Running deploy task 'energy_assets_serial_num'"

    identifier = 'energy-assets-serial-number'
    AmrDataFeedConfig.create!({
      identifier: identifier,
      description: 'Energy Assets Serial Number',
      notes: 'Adding energy assets format that includes serial number',
      number_of_header_rows: 1,
      mpan_mprn_field: 'MPRN',
      msn_field: 'SerialNum',
      reading_date_field: 'Date',
      date_format: '%d/%m/%y',
      header_example: 'MPRN,SerialNum,Date,Reading,hr0030,hr0100,hr0130,hr0200,hr0230,hr0300,hr0330,hr0400,hr0430,hr0500,hr0530,hr0600,hr0630,hr0700,hr0730,hr0800,hr0830,hr0900,hr0930,hr1000,hr1030,hr1100,hr1130,hr1200,hr1230,hr1300,hr1330,hr1400,hr1430,hr1500,hr1530,hr1600,hr1630,hr1700,hr1730,hr1800,hr1830,hr1900,hr1930,hr2000,hr2030,hr2100,hr2130,hr2200,hr2230,hr2300,hr2330,hr0000',
      reading_fields: 'hr0030,hr0100,hr0130,hr0200,hr0230,hr0300,hr0330,hr0400,hr0430,hr0500,hr0530,hr0600,hr0630,hr0700,hr0730,hr0800,hr0830,hr0900,hr0930,hr1000,hr1030,hr1100,hr1130,hr1200,hr1230,hr1300,hr1330,hr1400,hr1430,hr1500,hr1530,hr1600,hr1630,hr1700,hr1730,hr1800,hr1830,hr1900,hr1930,hr2000,hr2030,hr2100,hr2130,hr2200,hr2230,hr2300,hr2330,hr0000'.split(',')
    }) unless AmrDataFeedConfig.find_by_identifier(identifier)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
