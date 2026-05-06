# frozen_string_literal: true

module ImpactReports
  module Overview
    class StatsComponentPreview < ::ViewComponent::Preview
      # @param slug select :group_options
      # @param bs5 toggle
      def default(bs5: false, slug: nil) # rubocop:disable Lint/UnusedMethodArgument
        school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
        impact_report = SchoolGroups::ImpactReport.new(school_group)
        render(ImpactReports::Overview::StatsComponent.new(impact_report: impact_report))
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
