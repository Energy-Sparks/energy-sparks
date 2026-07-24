# frozen_string_literal: true

module ImpactReports
  module PotentialSavings
    class MetricsComponentPreview < ::ViewComponent::Preview
      # @param slug select :group_options
      # @param bs5 toggle
      def default(bs5: true, slug: nil) # rubocop:disable Lint/UnusedMethodArgument
        school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
        render(ImpactReports::PotentialSavings::MetricsComponent.new(run: school_group.latest_impact_report_run))
      end

      private

      def group_options
        {
          choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
        }
      end
    end
  end
end
