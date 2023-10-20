namespace :after_party do
  desc 'Deployment task: create_opus_gas_data_feed_config'
  task create_opus_gas_data_feed_config: :environment do
    puts "Running deploy task 'create_opus_gas_data_feed_config'"

    config = {}
    config['description'] = "Opus gas"
    config['identifier'] = 'opus-gas'
    config['number_of_header_rows'] = 1
    config['header_example'] = "MPAN,ReadingDate,ReadTime,MeterConsumption"
    config['date_format'] = "%d/%m/%Y" # e.g. 31/12/2023
    config['mpan_mprn_field'] = 'MPAN'
    config['reading_date_field'] = 'ReadingDate'
    config['reading_time_field'] = 'ReadTime'
    config['reading_fields'] = ['MeterConsumption']
    config['positional_index'] = true
    config['row_per_reading'] = true

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
