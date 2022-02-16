namespace :after_party do
  desc 'Deployment task: Remove tariffs that should have been deleted'
  task remove_old_tariffs: :environment do
    puts "Running deploy task 'remove_old_tariffs'"

    #The associations for tariff_prices and tariff_standing_charges on the
    #Meter class were using the default strategy (nullify) following a delete.
    #So the data hasn't actually been removed.
    #The code has been changed to add dependent: destroy, but we need to clean up
    #Use delete all to do it in a single SQL statement
    TariffPrice.where(meter: nil).delete_all
    TariffStandingCharge.where(meter: nil).delete_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
