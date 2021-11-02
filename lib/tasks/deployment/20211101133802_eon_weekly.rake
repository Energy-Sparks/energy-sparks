namespace :after_party do
  desc 'Deployment task: eon_weekly'
  task eon_weekly: :environment do
    puts "Running deploy task 'eon_weekly'"

    config = {}
    config['description'] = "Eon"
    config['identifier'] = 'eon'
    config['date_format'] = "%d/%m/%Y"
    config['mpan_mprn_field'] = 'MPAN'
    config['reading_date_field'] = 'DATE'
    config['reading_fields'] = '30,100,130,200,230,300,330,400,430,500,530,600,630,700,730,800,830,900,930,1000,1030,1100,1130,1200,1230,1300,1330,1400,1430,1500,1530,1600,1630,1700,1730,1800,1830,1900,1930,2000,2030,2100,2130,2200,2230,2300,2330,2400'.split(',')
    config['header_example'] = 'MPAN,DATE,30,100,130,200,230,300,330,400,430,500,530,600,630,700,730,800,830,900,930,1000,1030,1100,1130,1200,1230,1300,1330,1400,1430,1500,1530,1600,1630,1700,1730,1800,1830,1900,1930,2000,2030,2100,2130,2200,2230,2300,2330,2400'
    config['number_of_header_rows'] = 1

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
