namespace :after_party do
  desc 'Deployment task: Change autovacuum settings for amr_validated_readings'
  task validated_reading_vacuum: :environment do
    puts "Running deploy task 'validated_reading_vacuum'"

    ActiveRecord::Base.connection.execute('ALTER TABLE amr_validated_readings SET (autovacuum_vacuum_cost_delay = 0)')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
