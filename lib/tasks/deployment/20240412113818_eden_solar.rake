namespace :after_party do
  desc 'Deployment task: Eden solar config'
  task eden_solar: :environment do
    puts "Running deploy task 'eden_solar'"

    config = {}
    config['description'] = "Eden Solar"
    config['identifier'] = 'eden-solar'
    config['notes'] = "Format for loading solar generation data from Eden. Uses serial numbers"
    config['number_of_header_rows'] = 1
    config['date_format'] = "%Y-%m-%d"

    config['header_example'] = "MeterName,Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,1
4:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30"
    config['mpan_mprn_field'] = '' # must not be null, but wont be used
    config['msn_field'] = 'MeterName'
    config['lookup_by_serial_number'] = true
    config['reading_date_field'] = 'Date'
    config['reading_fields'] = "00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,1
4:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30".split(",")

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
