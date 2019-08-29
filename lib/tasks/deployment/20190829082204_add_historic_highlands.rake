namespace :after_party do
  desc 'Deployment task: add_historic_highlands'
  task add_historic_highlands: :environment do
    puts "Running deploy task 'add_historic_highlands'"

    reading_fields = "HH01,HH02,HH03,HH04,HH05,HH06,HH07,HH08,HH09,HH10,HH11,HH12,HH13,HH14,HH15,HH16,HH17,HH18,HH19,HH20,HH21,HH22,HH23,HH24,HH25,HH26,HH27,HH28,HH29,HH30,HH31,HH32,HH33,HH34,HH35,HH36,HH37,HH38,HH39,HH40,HH41,HH42,HH43,HH44,HH45,HH46,HH47,HH48"
    header_example = "MPN,Date (Local),Total,HH01,Type,HH02,Type,HH03,Type,HH04,Type,HH05,Type,HH06,Type,HH07,Type,HH08,Type,HH09,Type,HH10,Type,HH11,Type,HH12,Type,HH13,Type,HH14,Type,HH15,Type,HH16,Type,HH17,Type,HH18,Type,HH19,Type,HH20,Type,HH21,Type,HH22,Type,HH23,Type,HH24,Type,HH25,Type,HH26,Type,HH27,Type,HH28,Type,HH29,Type,HH30,Type,HH31,Type,HH32,Type,HH33,Type,HH34,Type,HH35,Type,HH36,Type,HH37,Type,HH38,Type,HH39,Type,HH40,Type,HH41,Type,HH42,Type,HH43,Type,HH44,Type,HH45,Type,HH46,Type,HH47,Type,HH48,Type"

    AmrDataFeedConfig.where(
      description: 'Highlands Historic',
      s3_folder: 'highlands-historic',
      s3_archive_folder: 'archive-highlands-historic',
      local_bucket_path: 'tmp/amr_files_bucket/highlands-historic',
      access_type: 'Email',
      date_format: "%e %b %Y %H:%M:%S",
      mpan_mprn_field: 'MPN',
      reading_date_field: 'Date (Local)',
      reading_fields: reading_fields.split(','),
      header_example: header_example
    ).first_or_create

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
