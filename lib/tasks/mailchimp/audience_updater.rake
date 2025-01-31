namespace :mailchimp do
  desc "Push database changes to Mailchimp"
  task :audience_updater, [:dir] => :environment do |t,args|
    Mailchimp::AudienceUpdaterJob.perform_later
    puts "Job submitted"
  end
end
