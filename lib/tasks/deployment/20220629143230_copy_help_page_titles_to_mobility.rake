namespace :after_party do
  desc 'Deployment task: copy_help_page_titles_to_mobility'
  task copy_help_page_titles_to_mobility: :environment do
    puts "Running deploy task 'copy_help_page_titles_to_mobility'"

    HelpPage.transaction do
      HelpPage.all.each do |help_page|
        help_page.update(title: help_page.read_attribute(:title))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
