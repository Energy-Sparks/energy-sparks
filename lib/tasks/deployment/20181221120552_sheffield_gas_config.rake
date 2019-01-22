namespace :after_party do
  desc 'Deployment task: sheffield_gas_config'
  task sheffield_gas_config: :environment do
    puts "Running deploy task 'sheffield_gas_config'"

    england = CalendarArea.find_by(title: 'England and Wales')
    area = CalendarArea.where(title: 'Sheffield', parent_area: england).first_or_create

    AmrDataFeedConfig.where(
      area_id: area.id,
      description: 'Sheffield Gas',
      s3_folder: 'sheffield-gas',
      s3_archive_folder: 'archive-sheffield-gas',
      local_bucket_path: 'tmp/amr_files_bucket/sheffield-gas',
      access_type: 'Email',
      date_format: "%d/%m/%Y",
      mpan_mprn_field: '"MPR"',
      reading_date_field: '"Date"',
      reading_fields: '"hr0030","hr0100","hr0130","hr0200","hr0230","hr0300","hr0330","hr0400","hr0430","hr0500","hr0530","hr0600","hr0630","hr0700","hr0730","hr0800","hr0830","hr0900","hr0930","hr1000","hr1030","hr1100","hr1130","hr1200","hr1230","hr1300","hr1330","hr1400","hr1430","hr1500","hr1530","hr1600","hr1630","hr1700","hr1730","hr1800","hr1830","hr1900","hr1930","hr2000","hr2030","hr2100","hr2130","hr2200","hr2230","hr2300","hr2330","hr0000"'.split(','),
      header_example: '"MPR","Date","hr0030","hr0100","hr0130","hr0200","hr0230","hr0300","hr0330","hr0400","hr0430","hr0500","hr0530","hr0600","hr0630","hr0700","hr0730","hr0800","hr0830","hr0900","hr0930","hr1000","hr1030","hr1100","hr1130","hr1200","hr1230","hr1300","hr1330","hr1400","hr1430","hr1500","hr1530","hr1600","hr1630","hr1700","hr1730","hr1800","hr1830","hr1900","hr1930","hr2000","hr2030","hr2100","hr2130","hr2200","hr2230","hr2300","hr2330","hr0000"'
    ).first_or_create


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20181221120552'
  end
end
