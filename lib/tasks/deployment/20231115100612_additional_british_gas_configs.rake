namespace :after_party do
  desc 'Deployment task: additional_british_gas_configs'
  task additional_british_gas_configs: :environment do
    puts "Running deploy task 'additional_british_gas_configs'"

    config = {}
    config['description'] = "British Gas Portal (Electricity only)"
    config['identifier'] = 'british-gas-portal-electricity'

    config['number_of_header_rows'] = 3
    config['header_example'] = "Group Name,Type,Generation Type,Site Name,Address Line 1,MPAN,Reading Date,Data Quality(% Complete),Consumption (kWh),Meter Read Type,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00,File Received At,File Name"
    config['mpan_mprn_field'] = 'MPAN'
    config['reading_date_field'] = 'Reading Date'
    config['date_format'] = "%d/%m/%Y" # e.g. 16/10/2023
    config['reading_fields'] = "00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00".split(",")
    config['total_field'] = 'Consumption (kWh)'
    config['column_row_filters'] = {"Meter Read Type"=>"^RE|^RI"}

    config['notes'] = 'This is format for electricity meter data exported from the portal'
    AmrDataFeedConfig.create!(config)

    config = {}
    config['description'] = "British Gas Portal (Gas only)"
    config['identifier'] = 'british-gas-portal-gas'

    config['number_of_header_rows'] = 3
    config['header_example'] = "Group Name,Site Name,Address Line 1,MPRN,Reading Date,Data Quality(% Complete),Consumption (kWh),00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00,File Received At,File Name"
    config['mpan_mprn_field'] = 'MPRN'
    config['reading_date_field'] = 'Reading Date'
    config['date_format'] = "%d/%m/%Y" # e.g. 16/10/2023
    config['reading_fields'] = "00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00".split(",")
    config['total_field'] = 'Consumption (kWh)'

    config['notes'] = 'This is format for gas meter data exported from the portal'
    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
