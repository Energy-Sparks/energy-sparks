namespace :after_party do
  desc 'Deployment task: meter_online_solar'
  task meter_online_solar: :environment do
    puts "Running deploy task 'meter_online_solar'"

    unless AmrDataFeedConfig.find_by_identifier('meter-online-solar')
      AmrDataFeedConfig.create!({
        identifier: 'meter-online-solar',
        description: 'Meter Online Solar data',
        notes: 'Manual upload format after data has been manually adjusted',
        source_type: :manual,
        number_of_header_rows: 2,
        positional_index: true,
        row_per_reading: true,
        mpan_mprn_field: 'MPAN',
        reading_date_field: 'Start Date',
        reading_time_field: 'Reading Time',
        half_hourly_labelling: :start,
        date_format: '%d-%m-%y',
        owned_by: User.find(6099),
        header_example: 'MPAN,Start Date,Reading Time,End Date,End Time,kWh',
        reading_fields: ['kWh']
      })
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
