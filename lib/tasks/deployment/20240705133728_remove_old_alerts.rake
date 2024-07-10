namespace :after_party do
  desc 'Deployment task: remove_old_alerts'
  task remove_old_alerts: :environment do
    puts "Running deploy task 'remove_old_alerts'"

    # Disable last few of the old analysis pages
    AlertType.where(class_name: ['AdviceGasBoilerFrost', 'AdviceElectricityMeterBreakdownBase', 'AdviceGasMeterBreakdownBase']).update_all(enabled: false)

    # Remove all disabled AlertTypes. This includes
    # - the alerts responsible for old analysis pages, including the above
    #   these were disabled and haven't been used in last year
    #
    # - some older alerts responsible for comparison reports and some unused dashboard reports
    #   these were also disabled some time ago so haven't been run
    AlertType.where(enabled: false).destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
