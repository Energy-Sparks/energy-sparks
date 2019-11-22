namespace :after_party do
  desc 'Deployment task: remove_duplicate_alert_type'
  task remove_duplicate_alert_type: :environment do
    puts "Running deploy task 'remove_duplicate_alert_type'"

    gas_intraday_alert_types = AlertType.where(class_name: 'AdviceGasIntraday').to_a
    to_destroy = gas_intraday_alert_types.select{|alert_type| alert_type.ratings.empty? || alert_type.ratings.none?{|rating| rating.analysis_active?}}

    to_destroy.map(&:destroy)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
