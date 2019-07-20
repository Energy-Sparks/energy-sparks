namespace :after_party do
  desc 'Deployment task: add_new_alert_types'
  task add_new_alert_types: :environment do
    puts "Running deploy task 'add_new_alert_types'"

    # Put your task implementation HERE.
    # Electric
    ActiveRecord::Base.transaction do
      AlertType.where(
        source: :analytics,
        fuel_type: :electricity,
        frequency: :termly,
        class_name: 'AlertMeterASCLimit',
        title: 'Meter ASC Limit',
        description: 'For large (school) electricity consumers checks to see there is a benefit in reducing the Agreed Supply Capacity (ASC) limit to reduce standing charges').first_or_create!

      AlertType.where(
        source: :analytics,
        fuel_type: :electricity,
        frequency: :termly,
        class_name: 'AlertDifferentialTariffOpportunity',
        title: 'Differential Tariff Opportunity',
        description: 'Assesses whether switching to, or away from a differential tariff (e.g. economy 7) might save costs').first_or_create!

      AlertType.where(
        source: :analytics,
        fuel_type: :electricity,
        frequency: :termly,
        class_name: 'AlertElectricityMeterConsolidationOpportunity',
        title: 'Electricity Meter Consolidation Opportunity',
        description: 'For schools with multiple electricity meters, suggests the cost benefits of reducing the number of meters').first_or_create!
    end

    # Gas
    ActiveRecord::Base.transaction do
      AlertType.where(
        source: :analytics,
        fuel_type: :gas,
        frequency: :termly,
        class_name: 'AlertGasMeterConsolidationOpportunity',
        title: 'Gas Meter Consolidation Opportunity',
        description: 'For schools with multiple gas meters, suggests the cost benefits of reducing the number of meters').first_or_create!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
