namespace :after_party do
  desc 'Deployment task: new_edf_format'
  task new_edf_format: :environment do
    puts "Running deploy task 'new_edf_format'"

    config = {}
    config['description'] = "EDF Format 2 (2021)"
    config['identifier'] = 'edf-format-2'
    config['date_format'] = "%e %b %Y %H:%M:%S"
    config['header_example'] = 'MPR,ReadDatetime,kWh,ReadType'
    config['mpan_mprn_field'] = 'MPR'
    config['reading_date_field'] = 'ReadDatetime'
    config['reading_fields'] = 'kWh'.split(',')
    config['number_of_header_rows'] = 1
    config['row_per_reading'] = true

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
