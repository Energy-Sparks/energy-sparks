namespace :after_party do
  desc 'Deployment task: remove_n3rgy_zero_tariff_standing_charges'
  task remove_n3rgy_zero_tariff_standing_charges: :environment do
    puts "Running deploy task 'remove_n3rgy_zero_tariff_standing_charges'"

    # Put your task implementation HERE.
    ActiveRecord::Base.transaction do
      tariff_standing_charges = TariffStandingCharge.joins(:meter)
                                                    .joins(:tariff_import_log)
                                                    .where("tariff_import_logs.source = 'n3rgy-api'")
                                                    .where('meters.dcc_meter = true')
                                                    .where('value <= 0.0')

      tariff_standing_charges.delete_all
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end