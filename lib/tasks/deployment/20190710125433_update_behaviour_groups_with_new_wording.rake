# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: update_behaviour_groups_with_new_wording'
  task update_behaviour_groups_with_new_wording: :environment do
    puts "Running deploy task 'update_behaviour_groups_with_new_wording'"

    behaviour_group = InterventionTypeGroup.find_by!(title: 'Behaviour change')
    behaviour_group.intervention_types.find_by!(title: 'Ran a campaign to keep the doors and windows closed when the heating is on.').update!(title: 'Started a campaign to keep the doors and windows closed when the heating is on')
    behaviour_group.intervention_types.find_by!(title: 'Ran a switch-off campaign').update!(title: 'Started a switch-off campaign')

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
