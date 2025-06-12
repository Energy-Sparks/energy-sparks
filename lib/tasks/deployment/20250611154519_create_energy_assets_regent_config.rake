namespace :after_party do
  desc 'Deployment task: create_energy_assets_regent_config'
  task create_energy_assets_regent_config: :environment do
    puts "Running deploy task 'create_energy_assets_regent_config'"

    AmrDataFeedConfig.find_or_create_by!(identifier: 'energy-assets-regent') do |config|
      config.assign_attributes(
        description: 'Energy Assets Regent',
        number_of_header_rows: 1,
        mpan_mprn_field: 'MPRN',
        reading_date_field: 'Date',
        date_format: '%d/%m/%Y',
        header_example: 'UtilityType,MPRN,SerialNum,Unit,Date,Reading,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30',
        reading_fields: '00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'.split(',')
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
