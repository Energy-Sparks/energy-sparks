namespace :after_party do
  desc 'Deployment task: add_navigation_feature'
  task add_navigation_feature: :environment do
    puts "Running deploy task 'add_navigation_feature'"

    Flipper.add(:navigation)
    # To enable feature for a specific user:
    # user = User.find_by(email: 'deb.bassett@energysparks.uk')
    # Flipper.enable_actor(:navigation, user)

    # To enable feature for a school group:
    # group = SchoolGroup.find_by(slug: 'name')
    # Flipper.enable_actor(:navigation, group)

    # To add actors via the admin interface, you must input the flipper id
    # This can be found by calling flipper_id on the actor. e.g.
    # user.flipper_id
    # or
    # group.flipper_id

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
