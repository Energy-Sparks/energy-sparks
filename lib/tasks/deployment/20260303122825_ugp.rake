namespace :after_party do
  desc 'Deployment task: United gas and power'
  task ugp: :environment do
    puts "Running deploy task 'ugp'"

    AmrDataFeedConfig.find_or_create_by!(identifier: 'ugp') do |config|
      config.assign_attributes(
        description: 'United Gas and Power',
        notes: '',
        number_of_header_rows: 1,
        mpan_mprn_field: 'Meter Point',
        reading_date_field: 'Date',
        reading_time_field: 'Time Slot',
        date_format: 'n/a',
        header_example: 'Fuel,Meter Point,Date,Time Slot,Consumption,Company',
        reading_fields: ['Consumption'],
        row_per_reading: true,
        positional_index: true
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
