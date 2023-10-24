namespace :after_party do
  desc 'Deployment task: customise_vacuuming_of_reading_tables'
  task customise_vacuuming_of_reading_tables: :environment do
    puts "Running deploy task 'customise_vacuuming_of_reading_tables'"

    #amr_data_feed_readings

    #Reduce cost delay to complete autovacuum processes (vacuum, analyse) as quickly as possible
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_data_feed_readings SET (autovacuum_vacuum_cost_delay = 0)")

    #Set scale factor to zero, rather than 0.05 so that we trigger the autovacuum process to run ANALYSE based on number of
    #records changed, not a % of the table.
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_data_feed_readings SET (autovacuum_analyze_scale_factor = 0)")
    #Increase analyse threshold from 50, so we will run analyse every 10000 rows
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_data_feed_readings SET (autovacuum_analyze_threshold = 10000)")

    #Repeat the above settings but for controlling how often VACUUM is run. Use larger threshold for
    #vacuum as its more expensive
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_data_feed_readings SET (autovacuum_vacuum_scale_factor = 0)")
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_data_feed_readings SET (autovacuum_vacuum_threshold = 50000)")

    #amr_validated_readings
    #This is already set, but reapplying here for documentation purposes
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_validated_readings SET (autovacuum_vacuum_cost_delay = 0)")

    #Set scale factor to zero, rather than 0.05 so that we trigger the autovacuum process to run ANALYSE based on number of
    #records changed, not a % of the table.
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_validated_readings SET (autovacuum_analyze_scale_factor = 0)")
    #Increase analyse threshold from 50, so we will run analyse every 10000 rows
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_validated_readings SET (autovacuum_analyze_threshold = 10000)")

    #Repeat the above settings but for controlling how often VACUUM is run. Use larger threshold for
    #vacuum as its more expensive
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_validated_readings SET (autovacuum_vacuum_scale_factor = 0)")
    ActiveRecord::Base.connection.execute("ALTER TABLE amr_validated_readings SET (autovacuum_vacuum_threshold = 50000)")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
