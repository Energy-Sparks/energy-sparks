namespace :after_party do
  desc 'Deployment task: crown_row_per_reading'
  task crown_row_per_reading: :environment do
    puts "Running deploy task 'crown_row_per_reading'"

    new_config = {}
    new_config['description'] = 'Crown (row per reading)'
    new_config['identifier'] = 'crown-row'
    new_config['row_per_reading'] = true
    new_config['number_of_header_rows'] = 5
    new_config['date_format'] = '%d/%m/%Y %H:%M'
    new_config['mpan_mprn_field'] = '' #lookup by serial
    new_config['lookup_by_serial_number'] = true
    new_config['reading_date_field'] = 'DateTime'
    new_config['msn_field'] = 'MSN'
    new_config['allow_merging'] = true
    new_config['missing_readings_limit'] = 3
    new_config['half_hourly_labelling'] = :start
    new_config['header_example'] = 'MSN,DateTime,Kwh'
    new_config['reading_fields'] = ['Kwh']
    new_config['notes'] = 'Format for manually requested data from Crown'

    AmrDataFeedConfig.create!(new_config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
