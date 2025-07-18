namespace :after_party do
  desc 'Deployment task: allow_merging_cns'
  task allow_merging_cns: :environment do
    puts "Running deploy task 'allow_merging_cns'"

    AmrDataFeedConfig.where(identifier: 'ems-gas-cns').update_all(allow_merging: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
