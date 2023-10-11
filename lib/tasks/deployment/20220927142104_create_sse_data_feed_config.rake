namespace :after_party do
  desc 'Deployment task: create_sse_data_feed_config'
  task create_sse_data_feed_config: :environment do
    puts "Running deploy task 'create_sse_data_feed_config'"

    new_config = {}
    new_config['description'] = 'SSE'
    new_config['identifier'] = 'sse'
    new_config['number_of_header_rows'] = 1
    new_config['date_format'] = '%d/%m/%y'
    new_config['mpan_mprn_field'] = 'MPAN'
    new_config['reading_date_field'] = 'Date'
    new_config['reading_fields'] = '00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'.split(',')
    new_config['header_example'] = 'MPAN,Units,Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'
    new_config['column_row_filters'] = { 'Units' => 'LAG|LEAD' }

    AmrDataFeedConfig.create!(new_config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
