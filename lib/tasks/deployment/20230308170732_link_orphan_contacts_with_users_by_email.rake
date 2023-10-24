namespace :after_party do
  desc 'Deployment task: link_orphan_contacts_with_users_by_email'
  task link_orphan_contacts_with_users_by_email: :environment do
    puts "Running deploy task 'link_orphan_contacts_with_users_by_email'"

    orphan_contacts = Contact.where(user_id: nil)
    puts "#{orphan_contacts.count} orphans contacts found"

    orphan_contacts.each do |contact|
      if (user = User.find_by_email(contact.email_address.downcase))
        contact.update(user: user)
        puts "updated contact #{contact.id} with user #{user.id}"
      end
    end

    orphan_contacts = Contact.where(user_id: nil)
    puts "#{orphan_contacts.count} orphans contacts remaining"

    puts "Finished"

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
