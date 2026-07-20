# frozen_string_literal: true

module Tasks
  class HeaderPreview < ViewComponent::Preview
    # @param task_type select { choices: [activity_type, intervention_type] }
    def default(task_type: 'activity_type')
      task = if task_type == 'intervention_type'
               InterventionType.active.sample
             else
               ActivityType.active.sample
             end

      render(Tasks::Header.new(task: task))
    end

    # @param task_type select { choices: [activity_type, intervention_type] }
    def with_recording(task_type: 'activity_type')
      recording = if task_type == 'intervention_type'
                    Observation.intervention.sample
                  else
                    Activity.all.sample
                  end

      render(Tasks::Header.new(recording: recording))
    end
  end
end
