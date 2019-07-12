namespace :after_party do
  desc 'Deployment task: update_intervention_type_groups_with_new_copy'
  task update_intervention_type_groups_with_new_copy: :environment do
    puts "Running deploy task 'update_intervention_type_groups_with_new_copy'"

    ActiveRecord::Base.transaction do
      appliance_group = InterventionTypeGroup.find_by!(title: 'Appliance upgrades')
      appliance_group.update!(title: 'Upgrades to appliances')
      appliance_group.intervention_types.create!(title: 'Other', other: true)

      building_group = InterventionTypeGroup.find_by!(title: 'Building fabric changes')
      building_group.update!(title: 'Building fabric change')
      building_group.intervention_types.create!(title: 'Other', other: true)

      heating_group = InterventionTypeGroup.find_by!(title: 'Heating system changes')
      heating_group.update!(title: 'Heating system configuration change')
      heating_group.intervention_types.create!(title: 'Other', other: true)
      heating_group.intervention_types.find_by!(title: 'Changed central heating set temperature (specify temperature change...positive or negative change)').update!(title: 'Changed central heating set temperature')

      behaviour_group = InterventionTypeGroup.find_by!(title: 'Behaviour changes')
      behaviour_group.update!(title: 'Behaviour change')
      behaviour_group.intervention_types.create!(title: 'Other', other: true)
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
