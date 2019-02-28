namespace :after_party do
  desc 'Deployment task: add_design_and_technology_filter'
  task add_design_and_technology_filter: :environment do
    puts "Running deploy task 'add_design_and_technology_filter'"

    Subject.where(name: 'Design and Technology').first_or_create

    AfterParty::TaskRecord.create version: '20190228165829'
  end
end
