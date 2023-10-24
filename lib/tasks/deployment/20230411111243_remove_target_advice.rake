namespace :after_party do
  desc 'Deployment task: remove_target_advice'
  task remove_target_advice: :environment do
    puts "Running deploy task 'remove_target_advice'"

    ["AdviceTargetsElectricity", "AdviceTargetsGas"].each do |class_name|
      AlertType.find_by_class_name(class_name)&.destroy
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
