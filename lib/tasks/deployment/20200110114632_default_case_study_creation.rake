namespace :after_party do
  desc 'Deployment task: default_case_study_creation'
  task default_case_study_creation: :environment do
    puts "Running deploy task 'default_case_study_creation'"

    CaseStudy.transaction do

      case_study_1 = CaseStudy.new(
        position: 1,
        title: 'Case Study 1: Freshford Church School',
        description: 'Using energy information provided by Energy Sparks to reduce annual electricity costs by <strong>£740</strong>.',
      )
      case_study_1.file.attach(io: File.open(Rails.root.join('etc/Energy_Sparks_Case_Study_1_-_Freshford_Freezer.pdf')), filename: 'Energy_Sparks_Case_Study_1_-_Freshford_Freezer.pdf', content_type: 'application/pdf')
      case_study_1.save!

      case_study_2 = CaseStudy.new(
        position: 2,
        title: 'Case Study 2: Whiteways Primary School',
        description: 'Using energy information provided by Energy Sparks to save <strong>35%</strong> in annual gas use.',
      )
      case_study_2.file.attach(io: File.open(Rails.root.join('etc/Energy_Sparks_Case_Study_2_-_Whiteways_Boiler.pdf')), filename: 'Energy_Sparks_Case_Study_2_-_Whiteways_Boiler.pdf', content_type: 'application/pdf')
      case_study_2.save!

      case_study_3 = CaseStudy.new(
        position: 3,
        title: 'Case Study 3: Storage Heater Control',
        description: 'Using Energy Sparks to reduce storage heater costs by <strong>28%</strong>. This saving covered the installation cost within 16 weeks.',
      )
      case_study_3.file.attach(io: File.open(Rails.root.join('etc/Energy_Sparks_Case_Study_3_-_Stanton_Drew_Storage_Heaters.pdf')), filename: 'Energy_Sparks_Case_Study_3_-_Stanton_Drew_Storage_Heaters.pdf', content_type: 'application/pdf')
      case_study_3.save!

    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
