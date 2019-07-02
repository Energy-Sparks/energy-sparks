namespace :after_party do
  desc 'Deployment task: create_default_intervention_types'
  task create_default_intervention_types: :environment do
    puts "Running deploy task 'create_default_intervention_types'"

    ActiveRecord::Base.transaction do
      groups_and_types = {
        'Building fabric changes' => [
          'Upgraded interior lights to LED',
          'Upgraded security lights to LED',
          'Added solar PV',
          'Added loft insulation',
          'Added cavity wall insulation'
        ],
        'Appliance upgrades' => [
          'Upgraded kitchen appliances',
          'Upgraded IT servers',
          'Upgraded computers',
          'Upgraded whiteboards'
        ],
        'Heating system changes' => [
          'Changed central heating set temperature (specify temperature change...positive or negative change)',
          'Changed central heating operating times',
          'Adjusted radiator thermostats',
          'Replaced school boiler'
        ],
        'Behaviour changes' => [
          'Ran a switch-off campaign',
          'Ran a campaign to keep the doors and windows closed when the heating is on.'
        ]
      }

      groups_and_types.each do |group, types|
        group = InterventionTypeGroup.where(title: group).first_or_create!
        types.each do |type|
          group.intervention_types.where(title: type).first_or_create!
        end
      end
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
