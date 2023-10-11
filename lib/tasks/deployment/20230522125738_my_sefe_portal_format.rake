namespace :after_party do
  desc 'Deployment task: my_sefe_portal_format'
  task my_sefe_portal_format: :environment do
    puts "Running deploy task 'my_sefe_portal_format'"

    identifier = 'my-sefe-portal'
    config = {}
    config['identifier'] = identifier
    config['description'] = 'My SEFE Portal'
    config['notes'] = 'For processing data downloaded from the My SEFE Portal. Requires that the meter serial numbers are in Energy Sparks'
    config['header_example'] = 'ReadDateTime_UTC,MeterSerialNumber,Consumption'
    config['number_of_header_rows'] = 1
    config['date_format'] = '%d/%m/%Y %H:%M:%S'

    config['mpan_mprn_field'] = ''

    config['msn_field'] = 'MeterSerialNumber'
    config['reading_date_field'] = 'ReadDateTime_UTC'
    config['reading_fields'] = ['Consumption']

    config['row_per_reading'] = true
    config['lookup_by_serial_number'] = true

    amr_data_feed_config = AmrDataFeedConfig.find_by(identifier: identifier)
    if amr_data_feed_config
      amr_data_feed_config.update!(config)
    else
      AmrDataFeedConfig.create!(config)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
