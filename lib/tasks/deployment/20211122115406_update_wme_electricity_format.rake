namespace :after_party do
  desc 'Deployment task: update_wme_electricity_format'
  task update_wme_electricity_format: :environment do
    puts "Running deploy task 'update_wme_electricity_format'"

    config = AmrDataFeedConfig.find_by_identifier('wme-electricity')
    if config.present?
      config.header_example = 'Site Id,Meter Number,Data Type,Reading Date,00:30,DQ Flag,01:00,DQ Flag,01:30,DQ Flag,02:00,DQ Flag,02:30,DQ Flag,03:00,DQ Flag,03:30,DQ Flag,04:00,DQ Flag,04:30,DQ Flag,05:00,DQ Flag,05:30,DQ Flag,06:00,DQ Flag,06:30,DQ Flag,07:00,DQ Flag,07:30,DQ Flag,08:00,DQ Flag,08:30,DQ Flag,09:00,DQ Flag,09:30,DQ Flag,10:00,DQ Flag,10:30,DQ Flag,11:00,DQ Flag,11:30,DQ Flag,12:00,DQ Flag,12:30,DQ Flag,13:00,DQ Flag,13:30,DQ Flag,14:00,DQ Flag,14:30,DQ Flag,15:00,DQ Flag,15:30,DQ Flag,16:00,DQ Flag,16:30,DQ Flag,17:00,DQ Flag,17:30,DQ Flag,18:00,DQ Flag,18:30,DQ Flag,19:00,DQ Flag,19:30,DQ Flag,20:00,DQ Flag,20:30,DQ Flag,21:00,DQ Flag,21:30,DQ Flag,22:00,DQ Flag,22:30,DQ Flag,23:00,DQ Flag,23:30,DQ Flag,00:00,DQ Flag'
      config.mpan_mprn_field = 'Site Id'
      config.reading_date_field = 'Reading Date'
      config['number_of_header_rows'] = 1
      config['expected_units'] = nil
      config['units_field'] = nil
      config.save!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
