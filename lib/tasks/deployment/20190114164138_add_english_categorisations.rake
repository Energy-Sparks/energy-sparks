namespace :after_party do
  desc 'Deployment task: add_english_categorisations'
  task add_english_categorisations: :environment do
    puts "Running deploy task 'add_english_categorisations'"

    ActiveRecord::Base.transaction do
      Subject.where(name: 'English').first_or_create
      Topic.where(name: 'Articulate and justify arguments and opinions').first_or_create
    end

    AfterParty::TaskRecord.create version: '20190114164138'
  end
end
