namespace :issues do
  desc 'Issue report'
  task send_user_report: [:environment] do
    puts "#{Time.zone.now} send_user_report start - Sending weekly issues report to admins"
    if ENV['ENVIRONMENT_IDENTIFIER'] == 'production'
      User.admin.each do |user|
        if AdminMailer.with(user: user).issues_report.deliver
          puts "Issues report delivered to #{user.email}"
        else
          puts "No Issues to be sent to #{user.email}"
        end
      end
    else
      puts "#{Time.zone.now} Only sending report on the production server"
    end
    puts "#{Time.zone.now} send_user_report end - Finished sending weekly issues report to admins"
  end
end
