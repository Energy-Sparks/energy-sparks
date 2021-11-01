namespace :after_party do
  desc 'Deployment task: wme_electricity_config'
  task wme_electricity_config: :environment do
    puts "Running deploy task 'wme_electricity_config'"

    config = {}
    config['description'] = "WME Electricity"
    config['identifier'] = 'wme-electricity'
    config['date_format'] = "%d/%m/%Y"
    config['header_example'] = 'Client,MPAN,MPAN2,Id,ReadingType,Units,Date,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00'
    config['mpan_mprn_field'] = 'MPAN'
    config['reading_date_field'] = 'Date'
    config['reading_fields'] = '00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00'.split(',')
    config['number_of_header_rows'] = 0
    config['expected_units'] = 'kWh'
    config['units_field'] = 'Units'

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
