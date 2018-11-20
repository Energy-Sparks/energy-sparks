namespace :after_party do
  desc 'Deployment task: add_ks_4_and_ks_5'
  task add_ks_4_and_ks_5: :environment do
    puts "Running deploy task 'add_ks_4_and_ks_5'"

    # Put your task implementation HERE.
    ks4_tag = ActsAsTaggableOn::Tag.where(name: 'KS4').first_or_create
    ks5_tag = ActsAsTaggableOn::Tag.where(name: 'KS5').first_or_create

    # Create a dummy tagging for KS3 otherwise we can't easily get it back when we create our check list of stages etc
    ActsAsTaggableOn::Tagging.where(tag_id: ks4_tag, taggable_type: nil, taggable_id: nil, context: 'key_stages').first_or_create
    ActsAsTaggableOn::Tagging.where(tag_id: ks5_tag, taggable_type: nil, taggable_id: nil, context: 'key_stages').first_or_create

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20181120105809'
  end
end
