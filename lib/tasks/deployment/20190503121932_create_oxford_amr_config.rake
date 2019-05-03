namespace :after_party do
  desc 'Deployment task: create_oxford_amr_config'
  task create_oxford_amr_config: :environment do
    puts "Running deploy task 'create_oxford_amr_config'"

    AmrDataFeedConfig.where(
      description: 'Oxfordshire',
      s3_folder: 'oxfordshire',
      s3_archive_folder: 'archive-oxfordshire',
      local_bucket_path: 'tmp/amr_files_bucket/oxfordshire',
      access_type: 'Email',
      date_format: "%d/%m/%Y",
      mpan_mprn_field: '"PENDING"',
      reading_date_field: '"Date"',
      reading_fields: 'PENDING'.split(','),
      header_example: 'PENDING'
    ).first_or_create

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190503121932'
  end
end
