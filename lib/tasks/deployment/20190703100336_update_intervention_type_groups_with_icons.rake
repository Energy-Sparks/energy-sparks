namespace :after_party do
  desc 'Deployment task: update_intervention_type_groups_with_icons'
  task update_intervention_type_groups_with_icons: :environment do
    puts "Running deploy task 'update_intervention_type_groups_with_icons'"

    ActiveRecord::Base.transaction do
      groups_and_icons = {
        'Building fabric changes' => 'building',
        'Appliance upgrades' => 'server',
        'Heating system changes' => 'temperature-high',
        'Behaviour changes' => 'brain'
      }
      groups_and_icons.each do |group, icon|
        group = InterventionTypeGroup.where(title: group).first_or_create!
        group.update!(icon: icon)
      end
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
