# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: create_solar_setup_tag'
  task create_solar_setup_tag: :environment do
    puts "Running deploy task 'create_solar_setup_tag'"

    tag = IssueTag.find_or_initialize_by(label: 'Solar setup')
    tag.update!(system_id: :solar_setup)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
