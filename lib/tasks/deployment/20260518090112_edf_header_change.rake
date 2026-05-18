# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: edf_header_change'
  task edf_header_change: :environment do
    puts "Running deploy task 'edf_header_change'"

    # EDF previous had a "sep=" line above header, now removed.
    AmrDataFeedConfig.where(identifier: 'edf').update(
      number_of_header_rows: 1
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
