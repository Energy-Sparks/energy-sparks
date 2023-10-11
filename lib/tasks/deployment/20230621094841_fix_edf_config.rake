namespace :after_party do
  desc 'Deployment task: fix_edf_config'
  task fix_edf_config: :environment do
    puts "Running deploy task 'fix_edf_config'"

    config = AmrDataFeedConfig.find_by(identifier: 'edf-historic')
    if config.present?
      config.update!(
        mpan_mprn_field: 'MPAN',
        description: 'EDF Historic (Latest version)',
        date_format: '%d-%m-%Y',
        header_example: 'MPAN,Date (UTC),Total kWh,00:00,Type,00:30,Type,01:00,Type,01:30,Type,02:00,Type,02:30,Type,03:00,Type,03:30,Type,04:00,Type,04:30,Type,05:00,Type,05:30,Type,06:00,Type,06:30,Type,07:00,Type,07:30,Type,08:00,Type,08:30,Type,09:00,Type,09:30,Type,10:00,Type,10:30,Type,11:00,Type,11:30,Type,12:00,Type,12:30,Type,13:00,Type,13:30,Type,14:00,Type,14:30,Type,15:00,Type,15:30,Type,16:00,Type,16:30,Type,17:00,Type,17:30,Type,18:00,Type,18:30,Type,19:00,Type,19:30,Type,20:00,Type,20:30,Type,21:00,Type,21:30,Type,22:00,Type,22:30,Type,23:00,Type,23:30,Type'
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
