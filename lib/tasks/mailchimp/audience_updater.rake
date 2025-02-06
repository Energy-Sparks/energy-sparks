namespace :mailchimp do
  desc "Push database changes to Mailchimp"
  task :audience_updater, [:dir] => :environment do |t,args|
    if ENV['ENVIRONMENT_IDENTIFIER'] == "production"
      Mailchimp::AudienceUpdaterJob.perform_later
      puts "Job submitted"
    else
      puts "Skipping as not in production"
    end
  end
end
