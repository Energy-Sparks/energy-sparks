namespace :after_party do
  desc 'Deployment task: remove_old_email_data'
  task remove_old_email_data: :environment do
    puts "Running deploy task 'remove_old_email_data'"

    Email.delete_all
    AlertSubscriptionEvent.delete_all

    AfterParty::TaskRecord.create version: '20190417100245'
  end
end
