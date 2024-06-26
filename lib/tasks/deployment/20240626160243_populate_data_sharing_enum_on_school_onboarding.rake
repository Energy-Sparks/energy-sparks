namespace :after_party do
  desc 'Deployment task: populate_data_sharing_enum_on_school_onboarding'
  task populate_data_sharing_enum_on_school_onboarding: :environment do
    puts "Running deploy task 'populate_data_sharing_enum_on_school_onboarding'"

    # Update existing school onboarding records to be consistent with previous
    # behaviour of the flag
    SchoolOnboarding.where(school_will_be_public: true).update_all(data_sharing: :public)
    SchoolOnboarding.where(school_will_be_public: false).update_all(data_sharing: :within_group)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
