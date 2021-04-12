namespace :after_party do
  desc 'Deployment task: New GDST Electricity feed format'
  task new_gdst_electricity: :environment do
    puts "Running deploy task 'new_gdst_electricity'"

    # Put your task implementation HERE.
    config = {}
    config['description'] = "GDST Electricity 2"
    config['identifier'] = 'gdst-electricity2'
    config['date_format'] = "%d/%m/%y"
    config['mpan_mprn_field'] = 'Site Id'
    config['msn_field'] = 'Meter Number'
    config['reading_date_field'] = 'Reading Date'
    config['reading_fields'] = '00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'.split(',')
    config['header_example'] = 'Site Id,Meter Number,Reading Date,00:00,00:00 Flag,00:30,00:30 Flag,01:00,01:00 Flag,01:30,01:30 Flag,02:00,02:00 Flag,02:30,02:30 Flag,03:00,03:00 Flag,03:30,03:30 Flag,04:00,04:00 Flag,04:30,04:30 Flag,05:00,05:00 Flag,05:30,05:30 Flag,06:00,06:00 Flag,06:30,06:30 Flag,07:00,07:00 Flag,07:30,07:30 Flag,08:00,08:00 Flag,08:30,08:30 Flag,09:00,09:00 Flag,09:30,09:30 Flag,10:00,10:00 Flag,10:30,10:30 Flag,11:00,11:00 Flag,11:30,11:30 Flag,12:00,12:00 Flag,12:30,12:30 Flag,13:00,13:00 Flag,13:30,13:30 Flag,14:00,14:00 Flag,14:30,14:30 Flag,15:00,15:00 Flag,15:30,15:30 Flag,16:00,16:00 Flag,16:30,16:30 Flag,17:00,17:00 Flag,17:30,17:30 Flag,18:00,18:00 Flag,18:30,18:30 Flag,19:00,19:00 Flag,19:30,19:30 Flag,20:00,20:00 Flag,20:30,20:30 Flag,21:00,21:00 Flag,21:30,21:30 Flag,22:00,22:00 Flag,22:30,22:30 Flag,23:00,23:00 Flag,23:30,23:30 Flag'
    config['number_of_header_rows'] = 1

    AmrDataFeedConfig.create!(config)
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
