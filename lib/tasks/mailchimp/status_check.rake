namespace :mailchimp do
  desc "Check mailchimp status of confirmed users"
  task :status_check, [:dir] => :environment do |t,args|
    Mailchimp::StatusCheckerJob.perform_later
  end
end
