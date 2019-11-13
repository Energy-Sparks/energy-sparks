namespace :after_party do
  desc 'Deployment task: backfill_alert_generation_runs'
  task backfill_alert_generation_runs: :environment do
    puts "Running deploy task 'backfill_alert_generation_runs'"

    # Put your task implementation HERE.

    alert_hour_count_hash = Alert.all.group("date_trunc('hour', created_at)").count

    alert_hour_count_hash.each do |trunc_date, _number_of_records|
      alerts_by_school = Alert.where("date_trunc('hour', created_at) = ?", trunc_date).group(:school_id).count

      alerts_by_school.each do |school_id, _number_of_school_records|
        alert_generation_run = AlertGenerationRun.create(school_id: school_id, created_at: trunc_date)
        Alert.where("date_trunc('hour', created_at) = ?", trunc_date).where(school_id: school_id).update_all(alert_generation_run_id: alert_generation_run.id)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
