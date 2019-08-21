namespace :after_party do
  desc 'Deployment task: setup_points_for_intervention_types'
  task setup_points_for_intervention_types: :environment do
    puts "Running deploy task 'setup_points_for_intervention_types'"

    ActiveRecord::Base.transaction do

      InterventionType.where.not(title: 'Other').update_all(points: 30)

      InterventionType.where(
        title: [
          'Added cavity wall insulation',
          'Added loft insulation',
          'Replaced school boiler'
        ]
      ).update_all(points: 50)

      InterventionType.find_by!(title: 'Adjusted radiator thermostats').update!(points: 10)
      InterventionType.find_by!(title: 'Added solar PV').update!(points: 100)
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
