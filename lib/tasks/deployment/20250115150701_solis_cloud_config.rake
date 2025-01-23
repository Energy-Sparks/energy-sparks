namespace :after_party do
  desc 'Deployment task: solis_cloud_config'
  task solis_cloud_config: :environment do
    puts "Running deploy task 'solis_cloud_config'"

    AmrDataFeedConfig.create!(
      description: 'SolisCloud',
      identifier: 'solis-cloud',
      date_format: 'YYYY-MM-DD',
      mpan_mprn_field: 'n/a',
      reading_date_field: 'n/a',
      reading_fields: [],
      process_type: :other_api
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
