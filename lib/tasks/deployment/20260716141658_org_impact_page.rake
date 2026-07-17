# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: org_impact_page'
  task org_impact_page: :environment do
    puts "Running deploy task 'org_impact_page'"

    Flipper.add(:org_impact_page)
    Flipper.enable_group(:org_impact_page, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
