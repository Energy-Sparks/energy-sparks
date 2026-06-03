# frozen_string_literal: true

namespace :issues do
  desc 'Issue report'
  task send_user_report: [:environment] do
    puts "#{Time.zone.now} send_user_report start - Sending weekly issues report to admins"
    User.admin.each do |user|
      if IssueReportMailer.with(user: user).issues_report.deliver
        puts "Issues report delivered to #{user.email}"
      else
        puts "No Issues to be sent to #{user.email}"
      end
    end
    puts "#{Time.zone.now} send_user_report end - Finished sending weekly issues report to admins"
  end
end
