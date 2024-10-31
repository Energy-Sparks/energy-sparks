namespace :after_party do
  desc 'Deployment task: tune_autovacuum_on_alerts'
  task tune_autovacuum_on_alerts: :environment do
    puts "Running deploy task 'tune_autovacuum_on_alerts'"

    # Reduce cost delay to complete autovacuum processes (vacuum, analyse) as quickly as possible
    ActiveRecord::Base.connection.execute("ALTER TABLE alerts SET (autovacuum_vacuum_cost_delay = 0)")

    #Set scale factor to zero, rather than 0.2 so that we trigger the autovacuum process to run ANALYZE based on number of
    #records changed, not a % of the table.
    ActiveRecord::Base.connection.execute("ALTER TABLE alerts SET (autovacuum_analyze_scale_factor = 0)")
    ActiveRecord::Base.connection.execute("ALTER TABLE alerts SET (autovacuum_analyze_threshold = 50000)")

    #Set scale factor to zero, rather than 0.2 so that we trigger the autovacuum process to run VACUUM based on number of
    #records changed, not a % of the table.
    ActiveRecord::Base.connection.execute("ALTER TABLE alerts SET (autovacuum_vacuum_scale_factor = 0)")
    ActiveRecord::Base.connection.execute("ALTER TABLE alerts SET (autovacuum_vacuum_threshold = 50000)")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
