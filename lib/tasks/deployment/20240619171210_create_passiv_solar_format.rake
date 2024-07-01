namespace :after_party do
  desc 'Deployment task: create_passiv_solar_format'
  task create_passiv_solar_format: :environment do
    puts "Running deploy task 'create_passiv_solar_format'"

    identifier = 'passiv-solar'
    AmrDataFeedConfig.create!({
      identifier: identifier,
      description: 'Passiv Solar Data',
      notes: 'Format for Passiv Solar Data. Note: this data config expects the dates to be the day AFTER the energy is consumed',
      delayed_reading: true,
      mpan_mprn_field: '', # must not be null, but wont be used
      lookup_by_serial_number: true,
      msn_field: 'Generation MSN',
      reading_date_field: 'Date/Time Stamp',
      date_format: '%Y-%m-%dT%H:%M:%SZ',
      header_example: 'Meter Type,Generation MSN,Latest Generation Meter Reading (kWh),Date/Time Stamp,00:00 - 00:30,00:30 - 01:00,01:00 - 01:30,01:30 - 02:00,02:00 - 02:30,02:30 - 03:00,03:00 - 03:30,03:30 - 04:0
0,04:00 - 04:30,04:30 - 05:00,05:00 - 05:30,05:30 - 06:00,06:00 - 06:30,06:30 - 07:00,07:00 - 07:30,07:30 - 08:00,08:00 - 08:30,08:30 - 09:00,09:00 - 09:30,09:30 - 10:00,10:00 - 10:30,10:30
- 11:00,11:00 - 11:30,11:30 - 12:00,12:00 - 12:30,12:30 - 13:00,13:00 - 13:30,13:30 - 14:00,14:00 - 14:30,14:30 - 15:00,15:00 - 15:30,15:30 - 16:00,16:00 - 16:30,16:30 - 17:00,17:00 - 17:30,
17:30 - 18:00,18:00 - 18:30,18:30 - 19:00,19:00 - 19:30,19:30 - 20:00,20:00 - 20:30,20:30 - 21:00,21:00 - 21:30,21:30 - 22:00,22:00 - 22:30,22:30 - 23:00,23:00 - 23:30,23:30 - 00:00',
      reading_fields: '00:00 - 00:30,00:30 - 01:00,01:00 - 01:30,01:30 - 02:00,02:00 - 02:30,02:30 - 03:00,03:00 - 03:30,03:30 - 04:0
0,04:00 - 04:30,04:30 - 05:00,05:00 - 05:30,05:30 - 06:00,06:00 - 06:30,06:30 - 07:00,07:00 - 07:30,07:30 - 08:00,08:00 - 08:30,08:30 - 09:00,09:00 - 09:30,09:30 - 10:00,10:00 - 10:30,10:30
- 11:00,11:00 - 11:30,11:30 - 12:00,12:00 - 12:30,12:30 - 13:00,13:00 - 13:30,13:30 - 14:00,14:00 - 14:30,14:30 - 15:00,15:00 - 15:30,15:30 - 16:00,16:00 - 16:30,16:30 - 17:00,17:00 - 17:30,
17:30 - 18:00,18:00 - 18:30,18:30 - 19:00,19:00 - 19:30,19:30 - 20:00,20:00 - 20:30,20:30 - 21:00,21:00 - 21:30,21:30 - 22:00,22:00 - 22:30,22:30 - 23:00,23:00 - 23:30,23:30 - 00:00'.split(",")
    }) unless AmrDataFeedConfig.find_by_identifier(identifier)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
