namespace :targets do
  desc 'Send email to set first target'
  task admin_report: [:environment] do
    puts "#{Time.zone.now} admin_report start - Sending weekly target report to admins"
    if ENV['ENVIRONMENT_IDENTIFIER'] == "production"
      Targets::AdminReportService.new.send_email_report
    else
      puts "#{Time.zone.now} Only sending report on the production server"
    end
    puts "#{Time.zone.now} admin_report end - Finished sending weekly target report to admins"
  end
end
