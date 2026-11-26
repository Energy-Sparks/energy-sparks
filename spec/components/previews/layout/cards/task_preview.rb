# frozen_string_literal: true

module Layout
  module Cards
    class TaskPreview < ViewComponent::Preview
      # @param task_type select { choices: [activity_type, intervention_type] }
      # @param country select { choices: [england, scotland, wales] }
      # @param show_summary toggle
      def default(task_type: 'activity_type', country: 'england', show_summary: false)
        task = if task_type == 'intervention_type'
                 InterventionType.active.sample
               else
                 ActivityType.active.sample
               end

        render(Layout::Cards::Task.new(task: task, country: country, show_summary: show_summary))
      end
    end
  end
end
