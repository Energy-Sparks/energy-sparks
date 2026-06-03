namespace :after_party do
  desc 'Deployment task: set_default_import_warning_days'
  task set_default_import_warning_days: :environment do
    puts "Running deploy task 'set_default_import_warning_days'"

    DataSource.find_each do |data_source|
      data_source.update(import_warning_days: 10) unless data_source.import_warning_days
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
