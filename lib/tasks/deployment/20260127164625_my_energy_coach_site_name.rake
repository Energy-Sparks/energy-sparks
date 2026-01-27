namespace :after_party do
  desc 'Deployment task: my_energy_coach_site_name'
  task my_energy_coach_site_name: :environment do
    puts "Running deploy task 'my_energy_coach_site_name'"

    identifier = 'my-energy-coach-site-name'
    unless AmrDataFeedConfig.find_by_identifier(identifier)
      AmrDataFeedConfig.create!({
        identifier: identifier,
        description: 'My Energy Coach (Site Name)',
        notes: 'Another updated format including Site ID and Site Name',
        number_of_header_rows: 1,
        mpan_mprn_field: 'Meter Reference',
        reading_date_field: 'Reading Date',
        date_format: '%d/%m/%Y',
        header_example: 'Site ID,Meter Name,Meter Reference,Reading Date,Site Name,00:30,Data Marker,01:00,Data Marker,01:30,Data Marker,02:00,Data Marker,02:30,Data Marker,03:00,Data Marker,03:30,Data Marker,04:00,Data Marker,04:30,Data Marker,05:00,Data Marker,05:30,Data Marker,06:00,Data Marker,06:30,Data Marker,07:00,Data Marker,07:30,Data Marker,08:00,Data Marker,08:30,Data Marker,09:00,Data Marker,09:30,Data Marker,10:00,Data Marker,10:30,Data Marker,11:00,Data Marker,11:30,Data Marker,12:00,Data Marker,12:30,Data Marker,13:00,Data Marker,13:30,Data Marker,14:00,Data Marker,14:30,Data Marker,15:00,Data Marker,15:30,Data Marker,16:00,Data Marker,16:30,Data Marker,17:00,Data Marker,17:30,Data Marker,18:00,Data Marker,18:30,Data Marker,19:00,Data Marker,19:30,Data Marker,20:00,Data Marker,20:30,Data Marker,21:00,Data Marker,21:30,Data Marker,22:00,Data Marker,22:30,Data Marker,23:00,Data Marker,23:30,Data Marker,24:00,Data Marker,DST +0:30,Data Marker,DST +1:00,Data Marker',
        reading_fields: '00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,24:00'.split(',')
      })
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
