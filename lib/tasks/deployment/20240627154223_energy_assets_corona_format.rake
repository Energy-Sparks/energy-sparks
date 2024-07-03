namespace :after_party do
  desc 'Deployment task: energy_assets_corona_format'
  task energy_assets_corona_format: :environment do
    puts "Running deploy task 'energy_assets_corona_format'"

    identifier = 'energy-assets-corona'
    AmrDataFeedConfig.create!({
      identifier: identifier,
      description: 'Energy Assets Corona',
      notes: 'New format for the GDST daily gas data',
      number_of_header_rows: 1,
      row_per_reading: true,
      mpan_mprn_field: 'MPRN',
      reading_date_field: 'Date',
      date_format: '%d/%m/%Y',
      reading_time_field: 'Time',
      positional_index: true,
      header_example: 'MPRN,Date,Time,Meter Units,Meter Start Read,Consumption,KWH',
      reading_fields: 'KWH'.split(",")
    }) unless AmrDataFeedConfig.find_by_identifier(identifier)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
