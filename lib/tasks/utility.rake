namespace :utility do
  desc 'Stop raises error if automated emails are not turned on'
  task :check_automated_emails_on do
    top_level_tasks = Rake.application.top_level_tasks
    remaining_tasks = top_level_tasks.slice(top_level_tasks.index("utility:check_automated_emails_on") + 1..-1)
    abort("Aborting tasks #{remaining_tasks}: SEND_AUTOMATED_EMAILS is not set") unless ENV['SEND_AUTOMATED_EMAILS']
  end

  desc 'Prepare test server'
  task prepare_test_server: :environment do
    unless ENV['SEND_AUTOMATED_EMAILS']
      puts "Removing non Energy Sparks email addresses and mobile numbers"
      Contact.where.not(email_address: "hello@energysparks.uk").update_all(email_address: '', mobile_phone_number: '')

      puts "Resetting pupil passwords"
      User.pupil.update_all(pupil_password: '')
      User.pupil.all.each_with_index do |pupil, index|
        pupil.update!(pupil_password: "pupil#{index}")
      end
    end
  end
end
