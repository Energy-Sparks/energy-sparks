namespace :after_party do
  desc 'Deployment task: disable_tgp_energy_tariffs'
  task disable_tgp_energy_tariffs: :environment do
    puts "Running deploy task 'disable_tgp_energy_tariffs'"

    # TGP n3rgy (SMS)
    data_source = DataSource.find_by_id(52)
    if data_source
      data_source.update(load_tariffs: false)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
