# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: reassign_meter_suppliers_and_data_sources'
  task reassign_meter_suppliers_and_data_sources: :environment do
    puts "Running deploy task 'reassign_meter_suppliers_and_data_sources'"

    service = Meters::DataSourceAndSuppliersManager.new
    service.import_from_csv('./sample_meter_csv.csv')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
