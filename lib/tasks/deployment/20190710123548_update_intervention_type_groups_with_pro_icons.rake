namespace :after_party do
  desc 'Deployment task: update_intervention_type_groups_with_pro_icons'
  task update_intervention_type_groups_with_pro_icons: :environment do
    puts "Running deploy task 'update_intervention_type_groups_with_pro_icons'"

    {
      "Upgrades to appliances" => 'desktop',
      "Building fabric change" => 'school',
      "Heating system configuration change" => 'tachometer-alt',
      "Behaviour change" => 'head-side-brain'
    }.each do |title, icon|
      InterventionTypeGroup.find_by!(title: title).update!(icon: icon)
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
