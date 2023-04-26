namespace :after_party do
  desc 'Deployment task: digital_energy_feed'
  task digital_energy_feed: :environment do
    puts "Running deploy task 'digital_energy_feed'"

    new_config = {}
    new_config['description'] = 'Digital Energy'
    new_config['identifier'] = 'digital-energy'
    new_config['number_of_header_rows'] = 6
    new_config['date_format'] = '%d/%m/%Y'
    new_config['mpan_mprn_field'] = 'MPAN'
    new_config['reading_date_field'] = 'Date'

    new_config['msn_field'] = 'Serial'
    new_config['meter_description_field'] = 'Meter Name'
    new_config['total_field'] = 'Total'

    new_config['reading_fields'] = '0:30,1:00,1:30,2:00,2:30,3:00,3:30,4:00,4:30,5:00,5:30,6:00,6:30,7:00,7:30,8:00,8:30,9:00,9:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,0:00'.split(',')

    new_config['header_example'] = 'Meter Name,MPAN,Serial,Date,0:30,1:00,1:30,2:00,2:30,3:00,3:30,4:00,4:30,5:00,5:30,6:00,6:30,7:00,7:30,8:00,8:30,9:00,9:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,0:00,Total'

    AmrDataFeedConfig.create!(new_config)
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
