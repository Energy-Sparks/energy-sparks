namespace :after_party do
  desc 'Deployment task: copy_programme_type_document_links_to_mobility'
  task copy_programme_type_document_links_to_mobility: :environment do
    puts "Running deploy task 'copy_programme_type_document_links_to_mobility'"

    ProgrammeType.transaction do
      ProgrammeType.all.each do |programme_type|
        programme_type.update(document_link: programme_type.read_attribute(:document_link))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
