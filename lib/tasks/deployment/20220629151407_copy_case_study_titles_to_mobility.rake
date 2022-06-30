namespace :after_party do
  desc 'Deployment task: copy_case_study_titles_to_mobility'
  task copy_case_study_titles_to_mobility: :environment do
    puts "Running deploy task 'copy_case_study_titles_to_mobility'"

    CaseStudy.transaction do
      CaseStudy.all.each do |case_study|
        case_study.update(title: case_study.read_attribute(:title))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
