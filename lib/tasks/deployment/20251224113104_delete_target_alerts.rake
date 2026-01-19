namespace :after_party do
  desc 'Deployment task: delete_target_alerts'
  task delete_target_alerts: :environment do
    puts "Running deploy task 'delete_target_alerts'"

    %w[AlertElectricityTargetAnnual AlertElectricityTarget4Week AlertElectricityTarget1Week
       AlertGasTargetAnnual AlertGasTarget4Week AlertGasTarget1Week
       AlertStorageHeaterTargetAnnual AlertStorageHeaterTarget4Week AlertStorageHeaterTarget1Week].each do |class_name|
      AlertType.destroy_by(class_name:)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
