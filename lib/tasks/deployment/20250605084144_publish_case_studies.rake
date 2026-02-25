namespace :after_party do
  desc 'Deployment task: publish_case_studies'
  task publish_case_studies: :environment do
    puts "Running deploy task 'publish_case_studies'"

    CaseStudy.update_all(published: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
