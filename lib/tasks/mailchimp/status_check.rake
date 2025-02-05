namespace :mailchimp do
  desc "Check mailchimp status of confirmed users"
  task :status_check, [:dir] => :environment do |t,args|
    if ENV['ENVIRONMENT_IDENTIFIER'] == "production"
      Mailchimp::StatusCheckerJob.perform_later
      puts "Job submitted"
    else
      puts "Skipping as not in production"
    end
  end
end
