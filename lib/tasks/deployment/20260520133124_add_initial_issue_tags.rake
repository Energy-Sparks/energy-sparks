# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_initial_issue_tags'
  task add_initial_issue_tags: :environment do
    puts "Running deploy task 'add_initial_issue_tags'"

    IssueTag.create([
                      { label: 'Onboarding status' },
                      { label: 'Group review', system_id: :group_review },
                      { label: 'Solar setup' }
                    ])

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
