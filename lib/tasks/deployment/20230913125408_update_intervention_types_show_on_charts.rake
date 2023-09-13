namespace :after_party do
  desc 'Deployment task: update_intervention_types_show_on_charts'
  task update_intervention_types_show_on_charts: :environment do
    puts "Running deploy task 'update_intervention_types_show_on_charts'"

    # All actions in the "Training" category should not be shown on charts as these aren’t
    # direct interventions on usage
    InterventionTypeGroup.find_by(name: 'Training').intervention_types.update_all(show_on_charts: false)

    # All actions in "Upgrades to appliances" are for the electricity fuel type
    InterventionTypeGroup.find_by(name: 'Upgrades to appliances').intervention_types.each do |intervention_type|
      intervention_type.fuel_type << 'electricity'
      intervention_type.save!
    end

    # All actions in "Heating system configuration change" are for the gas fuel type
    InterventionTypeGroup.find_by(name: 'Heating system configuration change').intervention_types.each do |intervention_type|
      intervention_type.fuel_type << 'gas'
      intervention_type.save!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end