# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: set_operations_users'
  task set_operations_users: :environment do
    puts "Running deploy task 'set_operations_users'"

    ops_ids = [1, 1144, 6099, 5320, 787, 7837, 9437]

    ops_ids.each do |id|
      User.where(id: id).update(operations: true)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
