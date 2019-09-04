namespace :after_party do
  desc 'Deployment task: add_highlands'
  task add_highlands: :environment do
    puts "Running deploy task 'add_highlands'"

    AmrDataFeedConfig.where(
      description: 'Highlands',
      s3_folder: 'highlands',
      s3_archive_folder: 'archive-highlands',
      local_bucket_path: 'tmp/amr_files_bucket/highlands',
      access_type: 'Email',
      date_format: "%e %b %Y %H:%M:%S",
      mpan_mprn_field: 'MPR',
      reading_date_field: 'ReadDatetime',
      reading_fields: ['kWh'],
      header_example: 'MPR,ReadDatetime,kWh,ReadType',
      row_per_reading: true,
      number_of_header_rows: 2
    ).first_or_create

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
