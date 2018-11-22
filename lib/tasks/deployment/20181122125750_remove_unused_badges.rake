namespace :after_party do
  desc 'Deployment task: remove_unused_badges'
  task remove_unused_badges: :environment do
    puts "Running deploy task 'remove_unused_badges'"
    Merit::BadgesSash.where(badge_id: [4, 5]).delete_all
    AfterParty::TaskRecord.create version: '20181122125750'
  end
end
