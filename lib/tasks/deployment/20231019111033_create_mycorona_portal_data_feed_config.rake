namespace :after_party do
  desc 'Deployment task: create_mycorona_portal_data_feed_config'
  task create_mycorona_portal_data_feed_config: :environment do
    puts "Running deploy task 'create_mycorona_portal_data_feed_config'"

    config = {}
    config['description'] = "MyCorona Portal"
    config['identifier'] = 'mycorona-portal'
    config['number_of_header_rows'] = 1
    config['date_format'] = "%d/%m/%Y" # e.g. 01/06/2023
    config['mpan_mprn_field'] = 'Site Name'
    config['reading_date_field'] = 'Read date'
    config['reading_time_field'] = 'Time'
    config['reading_fields'] = [' Actual (KWH)']
    config['header_example'] = "Read date,Time,Site Name, Actual (KWH)"
    config['positional_index'] = true
    config['row_per_reading'] = true

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
