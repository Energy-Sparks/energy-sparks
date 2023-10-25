namespace :after_party do
  desc 'Deployment task: lock_users_for_archived_schools'
  task lock_users_for_archived_schools: :environment do
    puts "Running deploy task 'lock_users_for_archived_schools'"

    School.archived.each do |school|
      school.transaction do
        school.users.each do |user|
          next if user.has_other_schools?
          next if user.locked_at?

          user.lock_access!(send_instructions: false)
        end
      end
    end

    School.deleted.each do |school|
      school.transaction do
        school.users.each do |user|
          next if user.locked_at?

          user.contacts.for_school(school).first&.destroy
          user.lock_access!(send_instructions: false)
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end