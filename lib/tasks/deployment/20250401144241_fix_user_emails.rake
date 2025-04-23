namespace :after_party do
  desc 'Deployment task: fix_user_emails'
  task fix_user_emails: :environment do
    puts "Running deploy task 'fix_user_emails'"

    User.all.reject { |u| URI::MailTo::EMAIL_REGEXP.match?(u.email) }.each do |user|
      user.update(email: user.email.gsub(/[^[:ascii:]]/, ''))
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
