namespace :after_party do
  desc 'Deployment task: migrate_pupil_password'
  task migrate_pupil_password: :environment do
    puts "Running deploy task 'migrate_pupil_password'"

    User.find_each do |user|
      user.pupil_password = user.pupil_password_old unless user.pupil_password_old.nil?
      user.save(validate: false)
    end
    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
