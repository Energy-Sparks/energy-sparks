namespace :after_party do
  desc 'Deployment task: archive_pending_sms'
  task archive_pending_sms: :environment do
    puts "Running deploy task 'archive_pending_sms'"

    AlertSubscriptionEvent.where(status: :pending, communication_type: :sms).update_all(status: :archived)

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
