namespace :after_party do
  desc 'Deployment task: remove_old_email_data'
  task remove_old_email_data: :environment do
    puts "Running deploy task 'remove_old_email_data'"

    AlertSubscriptionEvent.delete_all
    Email.delete_all

    AfterParty::TaskRecord.create version: '20190417100245'
  end
end
