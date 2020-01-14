namespace :after_party do
  desc 'Deployment task: create_historic_gdst_feeds'
  task create_historic_gdst_feeds: :environment do
    puts "Running deploy task 'create_historic_gdst_feeds'"

    # Put your task implementation HERE.

    # GDST historic gas
    AmrDataFeedConfig.create!(
      description: 'GDST historic gas',
      identifier: 'gdst-historic-gas',
      date_format: "%d/%m/%Y",
      mpan_mprn_field: 'MPR',
      reading_date_field: 'Date',
      reading_fields: ["hr0030","hr0100","hr0130","hr0200","hr0230","hr0300","hr0330","hr0400","hr0430","hr0500","hr0530","hr0600","hr0630","hr0700","hr0730","hr0800","hr0830","hr0900","hr0930","hr1000","hr1030","hr1100","hr1130","hr1200","hr1230","hr1300","hr1330","hr1400","hr1430","hr1500","hr1530","hr1600","hr1630","hr1700","hr1730","hr1800","hr1830","hr1900","hr1930","hr2000","hr2030","hr2100","hr2130","hr2200","hr2230","hr2300","hr2330","hr0000"],
      column_separator: ',',
      header_example: 'MPR,Date,hr0030,hr0100,hr0130,hr0200,hr0230,hr0300,hr0330,hr0400,hr0430,hr0500,hr0530,hr0600,hr0630,hr0700,hr0730,hr0800,hr0830,hr0900,hr0930,hr1000,hr1030,hr1100,hr1130,hr1200,hr1230,hr1300,hr1330,hr1400,hr1430,hr1500,hr1530,hr1600,hr1630,hr1700,hr1730,hr1800,hr1830,hr1900,hr1930,hr2000,hr2030,hr2100,hr2130,hr2200,hr2230,hr2300,hr2330,hr0000',
      number_of_header_rows: 1,
      process_type: :s3_folder,
      source_type: :email,
      import_warning_days: 7
    )

    AmrDataFeedConfig.create!(
      description: 'GDST historic electricity',
      identifier: 'gdst-historic-electricity',
      date_format: "%d/%m/%Y",
      mpan_mprn_field: 'Site Id',
      reading_date_field: 'Reading Date',
      reading_fields: ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"],
      column_separator: ',',
      header_example: 'Site Id,Meter Number,Data Type,Reading Date,00:00,00:00 Flag,00:30,00:30 Flag,01:00,01:00 Flag,01:30,01:30 Flag,02:00,02:00 Flag,02:30,02:30 Flag,03:00,03:00 Flag,03:30,03:30 Flag,04:00,04:00 Flag,04:30,04:30 Flag,05:00,05:00 Flag,05:30,05:30 Flag,06:00,06:00 Flag,06:30,06:30 Flag,07:00,07:00 Flag,07:30,07:30 Flag,08:00,08:00 Flag,08:30,08:30 Flag,09:00,09:00 Flag,09:30,09:30 Flag,10:00,10:00 Flag,10:30,10:30 Flag,11:00,11:00 Flag,11:30,11:30 Flag,12:00,12:00 Flag,12:30,12:30 Flag,13:00,13:00 Flag,13:30,13:30 Flag,14:00,14:00 Flag,14:30,14:30 Flag,15:00,15:00 Flag,15:30,15:30 Flag,16:00,16:00 Flag,16:30,16:30 Flag,17:00,17:00 Flag,17:30,17:30 Flag,18:00,18:00 Flag,18:30,18:30 Flag,19:00,19:00 Flag,19:30,19:30 Flag,20:00,20:00 Flag,20:30,20:30 Flag,21:00,21:00 Flag,21:30,21:30 Flag,22:00,22:00 Flag,22:30,22:30 Flag,23:00,23:00 Flag,23:30,23:30 Flag',
      number_of_header_rows: 1,
      process_type: :s3_folder,
      source_type: :email,
      import_warning_days: 7,
      msn_field: 'Meter Number',
      units_field: 'kWh'
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
