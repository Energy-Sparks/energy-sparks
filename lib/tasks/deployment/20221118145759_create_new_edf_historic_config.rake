namespace :after_party do
  desc 'Deployment task: create_new_edf_historic_config'
  task create_new_edf_historic_config: :environment do
    puts "Running deploy task 'create_new_edf_historic_config'"

    AmrDataFeedConfig.find_by(identifier: 'edf-historic').update(description: 'EDF Historic (%d/%m/%Y date format)')

    new_config = {}
    new_config['description'] = 'EDF Historic (%d-%m-%Y date format)'
    new_config['identifier'] = 'edf-historic2'
    new_config['number_of_header_rows'] = 1
    new_config['date_format'] = '"%d-%m-%Y"'
    new_config['mpan_mprn_field'] = '"MPAN"'
    new_config['reading_date_field'] = '"Date (UTC)"'
    new_config['reading_fields'] = ['"00:00"', '"00:30"', '"01:00"', '"01:30"', '"02:00"', '"02:30"', '"03:00"', '"03:30"', '"04:00"', '"04:30"', '"05:00"', '"05:30"', '"06:00"', '"06:30"', '"07:00"', '"07:30"', '"08:00"', '"08:30"', '"09:00"', '"09:30"', '"10:00"', '"10:30"', '"11:00"', '"11:30"', '"12:00"', '"12:30"', '"13:00"', '"13:30"', '"14:00"', '"14:30"', '"15:00"', '"15:30"', '"16:00"', '"16:30"', '"17:00"', '"17:30"', '"18:00"', '"18:30"', '"19:00"', '"19:30"', '"20:00"', '"20:30"', '"21:00"', '"21:30"', '"22:00"', '"22:30"', '"23:00"', '"23:30"']
    new_config['header_example'] = '"MPAN","Date (UTC)","Total kWh","00:00","Type","00:30","Type","01:00","Type","01:30","Type","02:00","Type","02:30","Type","03:00","Type","03:30","Type","04:00","Type","04:30","Type","05:00","Type","05:30","Type","06:00","Type","06:30","Type","07:00","Type","07:30","Type","08:00","Type","08:30","Type","09:00","Type","09:30","Type","10:00","Type","10:30","Type","11:00","Type","11:30","Type","12:00","Type","12:30","Type","13:00","Type","13:30","Type","14:00","Type","14:30","Type","15:00","Type","15:30","Type","16:00","Type","16:30","Type","17:00","Type","17:30","Type","18:00","Type","18:30","Type","19:00","Type","19:30","Type","20:00","Type","20:30","Type","21:00","Type","21:30","Type","22:00","Type","22:30","Type","23:00","Type","23:30","Type",'

    # Example row
    # "MPAN","Date (UTC)","Total kWh","00:00","Type","00:30","Type","01:00","Type","01:30","Type","02:00","Type","02:30","Type","03:00","Type","03:30","Type","04:00","Type","04:30","Type","05:00","Type","05:30","Type","06:00","Type","06:30","Type","07:00","Type","07:30","Type","08:00","Type","08:30","Type","09:00","Type","09:30","Type","10:00","Type","10:30","Type","11:00","Type","11:30","Type","12:00","Type","12:30","Type","13:00","Type","13:30","Type","14:00","Type","14:30","Type","15:00","Type","15:30","Type","16:00","Type","16:30","Type","17:00","Type","17:30","Type","18:00","Type","18:30","Type","19:00","Type","19:30","Type","20:00","Type","20:30","Type","21:00","Type","21:30","Type","22:00","Type","22:30","Type","23:00","Type","23:30","Type",
    # "2100040970245","01-09-2018","18.2000","0.6000","Actual","0.6000","Actual","0.6000","Actual","0.6000","Actual","0.8000","Actual","0.6000","Actual","0.6000","Actual","0.6000","Actual","0.6000","Actual","0.6000","Actual","0.7000","Actual","0.6000","Actual","0.5000","Actual","0.4000","Actual","0.5000","Actual","0.6000","Actual","0.1000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.0000","Actual","0.2000","Actual","0.0000","Actual","0.1000","Actual","0.1000","Actual","0.3000","Actual","0.7000","Actual","0.7000","Actual","0.6000","Actual","0.6000","Actual","0.6000","Actual","0.6000","Actual","0.9000","Actual","0.6000","Actual","0.6000","Actual","0.7000","Actual","0.7000","Actual","0.6000","Actual"

    AmrDataFeedConfig.create!(new_config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
