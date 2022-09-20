namespace :after_party do
  desc 'Deployment task: add_new_data_feed_config'
  task add_new_data_feed_config: :environment do
    puts "Running deploy task 'add_new_data_feed_config'"

    new_config = {}
    new_config['description'] = ''
    new_config['identifier'] = ''
    new_config['date_format'] = ''
    new_config['mpan_mprn_field'] = ''
    new_config['reading_date_field'] = ''
    new_config['reading_fields'] = ''.split(',')
    new_config['header_example'] = ''
    new_config['number_of_header_rows'] = 1
    new_config['column_row_filters'] = {}

    AmrDataFeedConfig.create!(new_config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end