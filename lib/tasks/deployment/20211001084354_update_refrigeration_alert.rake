namespace :after_party do
  desc 'Deployment task: update_refrigeration_alert'
  task update_refrigeration_alert: :environment do
    puts "Running deploy task 'update_refrigeration_alert'"

    alert = AlertType.find_by_class_name("AlertSummerHolidayRefridgerationAnalysis")
    if alert
      alert.update(
        class_name: "AlertSummerHolidayRefrigerationAnalysis",
        title: "Impact of turning fridges and freezers off over the summer holidays"
      )
      alert.save!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
