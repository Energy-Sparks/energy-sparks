namespace :after_party do
  desc 'Deployment task: low_carbon_hub_amr_config_creation'
  task low_carbon_hub_amr_config_creation: :environment do
    puts "Running deploy task 'low_carbon_hub_amr_config_creation'"

    # Put your task implementation HERE.
    AmrDataFeedConfig.where(
      description: 'Low carbon hub',
      access_type: 'API',
      s3_folder: 'N/A',
      s3_archive_folder: 'N/A',
      local_bucket_path: 'N/A',
      date_format: 'N/A',
      reading_date_field: 'N/A',
      mpan_mprn_field: 'N/A',
      reading_fields: ['N/A']
    ).first_or_create

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
