namespace :after_party do
  desc 'Deployment task: create_config_for_sheffield_historical_gas'
  task create_config_for_sheffield_historical_gas: :environment do
    puts "Running deploy task 'create_config_for_sheffield_historical_gas'"

    england = CalendarArea.find_by(title: 'England and Wales')
    area = CalendarArea.where(title: 'Sheffield', parent_area: england).first_or_create

    AmrDataFeedConfig.where(
      area_id: area.id,
      description: 'Sheffield Historical Gas',
      s3_folder: 'sheffield-historical-gas',
      s3_archive_folder: 'archive-sheffield-historical-gas',
      local_bucket_path: 'tmp/amr_files_bucket/sheffield-historical-gas',
      access_type: 'Manual',
      date_format: "%d/%m/%Y",
      mpan_mprn_field: 'MPR Value',
      reading_date_field: 'read_date',
      reading_fields:   "hh01,hh02,hh03,hh04,hh05,hh06,hh07,hh08,hh09,hh10,hh11,hh12,hh13,hh14,hh15,hh16,hh17,hh18,hh19,hh20,hh21,hh22,hh23,hh24,hh25,hh26,hh27,hh28,hh29,hh30,hh31,hh32,hh33,hh34,hh35,hh36,hh37,hh38,hh39,hh40,hh41,hh42,hh43,hh44,hh45,hh46,hh47,hh48".split(','),
      meter_description_field: 'meter_identifier',
      header_example: "MPR Value,meter_identifier,read_date,hh01,hh02,hh03,hh04,hh05,hh06,hh07,hh08,hh09,hh10,hh11,hh12,hh13,hh14,hh15,hh16,hh17,hh18,hh19,hh20,hh21,hh22,hh23,hh24,hh25,hh26,hh27,hh28,hh29,hh30,hh31,hh32,hh33,hh34,hh35,hh36,hh37,hh38,hh39,hh40,hh41,hh42,hh43,hh44,hh45,hh46,hh47,hh48"
    ).first_or_create

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20181203214458'
  end
end
