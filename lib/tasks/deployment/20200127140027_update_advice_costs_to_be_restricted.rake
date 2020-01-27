namespace :after_party do
  desc 'Deployment task: update_advice_costs_to_be_restricted'
  task update_advice_costs_to_be_restricted: :environment do
    puts "Running deploy task 'update_advice_costs_to_be_restricted'"

    # Put your task implementation HERE.
    class_names = ['AdviceGasCosts', 'AdviceElectricityCosts']
    AlertType.where(class_name: class_names).update(user_restricted: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
