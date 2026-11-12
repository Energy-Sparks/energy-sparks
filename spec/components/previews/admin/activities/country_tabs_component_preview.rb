# frozen_string_literal: true

module Admin
  module Activities
    class CountryTabsComponentPreview < ViewComponent::Preview
      RESOURCES = {
        subject_areas: ::Activities::SubjectArea,
        learning_stages: LearningStage
      }.freeze

      # @param resource select { choices: [subject_areas, learning_stages] }
      # @param country select { choices: [england, scotland, wales] }
      def default(resource: 'subject_areas', country: 'england')
        resource_class = RESOURCES.fetch(resource.to_sym)

        render(Admin::Activities::CountryTabsComponent.new(country: country.to_sym, resource_class:))
      end
    end
  end
end
