namespace :after_party do
  desc 'Deployment task: assign_group_to_alert'
  task assign_group_to_alert: :environment do
    puts "Running deploy task 'assign_group_to_alert'"

    #Add all the benchmarking alerts to benchmarking group
    AlertType.analytics.where("class_name like ?", "%Benchmark").update_all(group: :benchmarking)

    #Add all the comparison alerts and baseload change to the change detection group
    AlertType.analytics.where("class_name like ?", "%Comparison%").update_all(group: :change)
    AlertType.find_by_class_name("AlertChangeInElectricityBaseloadShortTerm").update!(group: :change)

    #Add all the alerts focused on short term issues to priority group
    AlertType.find_by_class_name("AlertElectricityUsageDuringCurrentHoliday").update!(group: :priority)
    AlertType.find_by_class_name("AlertGasHeatingHotWaterOnDuringHoliday").update!(group: :priority)
    AlertType.find_by_class_name("AlertStorageHeaterHeatingOnDuringHoliday").update!(group: :priority)
    AlertType.find_by_class_name("AlertTurnHeatingOff").update!(group: :priority)
    AlertType.find_by_class_name("AlertTurnHeatingOffStorageHeaters").update!(group: :priority)
    AlertType.find_by_class_name("AlertImpendingHoliday").update!(group: :priority)
    AlertType.find_by_class_name("AlertWeekendGasConsumptionShortTerm").update!(group: :priority)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
