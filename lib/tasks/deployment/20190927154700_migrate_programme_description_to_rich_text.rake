namespace :after_party do
  desc 'Deployment task: migrate_programme_description_to_rich_text'
  task migrate_programme_description_to_rich_text: :environment do
    puts "Running deploy task 'migrate_programme_description_to_rich_text'"

    ActiveRecord::Base.transaction do
      ProgrammeType.all.each do |programme_type|
        programme_type.update!(description: programme_type._old_description)
      end

      Programme.all.each do |programme|
        programme.update!(description: programme._old_description)
      end

    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
