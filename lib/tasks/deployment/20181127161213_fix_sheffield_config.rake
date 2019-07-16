# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: fix_sheffield_config'
  task fix_sheffield_config: :environment do
    puts "Running deploy task 'fix_sheffield_config'"

    # Put your task implementation HERE.
    sheffield_config = AmrDataFeedConfig.find_by(description: 'Sheffield')
    sheffield_config.update(local_bucket_path: 'tmp/amr_files_bucket/sheffield')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20181127161213'
  end
end
