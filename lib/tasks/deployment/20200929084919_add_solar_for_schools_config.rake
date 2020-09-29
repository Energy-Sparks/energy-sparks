namespace :after_party do
  desc 'Deployment task: add_solar_for_schools_config'
  task add_solar_for_schools_config: :environment do
    puts "Running deploy task 'add_solar_for_schools_config'"

    # Put your task implementation HERE.
    energy_assets = {}
    energy_assets['description'] = "Solar For Schools"
    energy_assets['identifier'] = 'solar-for-schools'
    energy_assets['date_format'] = "%-d %m %Y"
    energy_assets['mpan_mprn_field'] = 'MPAN'
    energy_assets['reading_date_field'] = 'date'
    energy_assets['reading_fields'] = '12:00 AM,12:30 AM,1:00 AM,1:30 AM,2:00 AM,2:30 AM,3:00 AM,3:30 AM,4:00 AM,4:30 AM,5:00 AM,5:30 AM,6:00 AM,6:30 AM,7:00 AM,7:30 AM,8:00 AM,8:30 AM,9:00 AM,9:30 AM,10:00 AM,10:30 AM,11:00 AM,11:30 AM,12:00 PM,12:30 PM,1:00 PM,1:30 PM,2:00 PM,2:30 PM,3:00 PM,3:30 PM,4:00 PM,4:30 PM,5:00 PM,5:30 PM,6:00 PM,6:30 PM,7:00 PM,7:30 PM,8:00 PM,8:30 PM,9:00 PM,9:30 PM,10:00 PM,10:30 PM,11:00 PM,11:30 PM'.split(',')
    energy_assets['header_example'] = 'id,name,date,type,MPAN,12:00 AM,12:30 AM,1:00 AM,1:30 AM,2:00 AM,2:30 AM,3:00 AM,3:30 AM,4:00 AM,4:30 AM,5:00 AM,5:30 AM,6:00 AM,6:30 AM,7:00 AM,7:30 AM,8:00 AM,8:30 AM,9:00 AM,9:30 AM,10:00 AM,10:30 AM,11:00 AM,11:30 AM,12:00 PM,12:30 PM,1:00 PM,1:30 PM,2:00 PM,2:30 PM,3:00 PM,3:30 PM,4:00 PM,4:30 PM,5:00 PM,5:30 PM,6:00 PM,6:30 PM,7:00 PM,7:30 PM,8:00 PM,8:30 PM,9:00 PM,9:30 PM,10:00 PM,10:30 PM,11:00 PM,11:30 PM'
    energy_assets['number_of_header_rows'] = 1

    AmrDataFeedConfig.create!(energy_assets)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end