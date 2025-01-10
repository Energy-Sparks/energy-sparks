namespace :after_party do
  desc 'Deployment task: Custom Datavision Interval Report format'
  task datavision_custom: :environment do
    puts "Running deploy task 'datavision_custom'"

    identifier = 'datavision-custom'
    AmrDataFeedConfig.create!({
      identifier: identifier,
      description: 'Custom Datavision Report',
      notes: 'Custom format manually created from Datavision column format',
      row_per_reading: true,
      number_of_header_rows: 2,
      half_hourly_labelling: :end,
      mpan_mprn_field: 'MPAN',
      reading_date_field: 'Date/Time',
      date_format: '%d/%m/%Y %H:%M',
      header_example: 'MPAN,Date/Time,Energy (kWh),Data Quality',
      reading_fields: ['Energy (kWh)'],
      column_row_filters: {"Data Quality"=>"^Unknown"},
      missing_readings_limit: 2
    }) unless AmrDataFeedConfig.find_by_identifier(identifier)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
