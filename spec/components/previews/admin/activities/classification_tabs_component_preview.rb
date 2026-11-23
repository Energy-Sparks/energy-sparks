# frozen_string_literal: true

module Admin
  module Activities
    class ClassificationTabsComponentPreview < ViewComponent::Preview
      # @param current select { choices: [aim, duration, topic, subject_areas, learning_stages, focus] }
      # @param country select { choices: [england, scotland, wales] }
      def default(current: 'subject_areas', country: 'wales')
        render(Admin::Activities::ClassificationTabsComponent.new(current:, country:))
      end
    end
  end
end
