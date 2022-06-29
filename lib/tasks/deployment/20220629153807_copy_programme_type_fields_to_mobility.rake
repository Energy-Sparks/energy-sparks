namespace :after_party do
  desc 'Deployment task: copy_programme_type_fields_to_mobility'
  task copy_programme_type_fields_to_mobility: :environment do
    puts "Running deploy task 'copy_programme_type_fields_to_mobility'"

    ProgrammeType.transaction do
      ProgrammeType.all.each do |programme_type|
        programme_type.update(title: programme_type.read_attribute(:title))
        programme_type.update(short_description: programme_type.read_attribute(:short_description))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
