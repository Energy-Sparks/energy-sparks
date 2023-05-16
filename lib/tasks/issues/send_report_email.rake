namespace :issues do
  desc "Issue report"
  task send_report_email: :environment do
    user = User.find_by(email: 'deb.bassett@energysparks.uk')
    if AdminMailer.with(user: user).issues_report.deliver
      puts "Issues report delivered to #{user.email}"
    else
      puts "No Issues to be sent to #{user.email}"
    end
  end
end
