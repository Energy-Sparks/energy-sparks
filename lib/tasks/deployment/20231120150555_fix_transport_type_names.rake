namespace :after_party do
  desc 'Deployment task: fix_transport_type_names'
  task fix_transport_type_names: :environment do
    puts "Running deploy task 'fix_transport_type_names'"

    ActiveRecord::Base.connection.execute("update mobility_string_translations set translatable_type='TransportSurvey::TransportType' where translatable_type='TransportType'")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
