namespace :after_party do
  desc 'Deployment task: refresh_updated_comparisons'
  task refresh_updated_comparisons: :environment do
    puts "Running deploy task 'refresh_updated_comparisons'"

    Comparison::AnnualElectricityCostsPerPupil.refresh
    Comparison::AnnualHeatingCostsPerFloorArea.refresh

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
