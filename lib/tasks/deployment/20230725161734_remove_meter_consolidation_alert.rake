namespace :after_party do
  desc 'Deployment task: remove_meter_consolidation_alert'
  task remove_meter_consolidation_alert: :environment do
    puts "Running deploy task 'remove_meter_consolidation_alert'"

    # Delete unneeded attributes
    GlobalMeterAttribute.where(attribute_type: 'indicative_standing_charge').destroy_all

    %w[AlertGasMeterConsolidationOpportunity AlertElectricityMeterConsolidationOpportunity].each do |class_name|
      alert_type = AlertType.find_by(class_name: class_name)
      # remove all the alert records where we've run this, as it was still enabled for running
      # but not display
      Alert.where(alert_type: alert_type).destroy_all
      # remove the alert type from the database
      alert_type.destroy
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
