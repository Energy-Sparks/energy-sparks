namespace :after_party do
  desc 'Deployment task: perse_half_hourly_api'
  task perse_half_hourly_api: :environment do
    puts "Running deploy task 'perse_half_hourly_api'"

    AmrDataFeedConfig.create!(
      identifier: 'perse-half-hourly-api',
      process_type: 'other_api',
      source_type: 'api',
      description: 'Perse Half-Hourly Meter API',
      date_format: '%Y-%m-%d',
      mpan_mprn_field: 'N/A',
      reading_date_field: 'N/A',
      reading_fields: []
    )
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
