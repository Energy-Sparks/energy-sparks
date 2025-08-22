module Dashboards
  class GroupAlertsComponentPreview < ViewComponent::Preview
    # @param slug select :group_options
    # @param limit number
    # @param grouped toggle
    def example(slug: nil, limit: 3, grouped: false)
      school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
      render(Dashboards::GroupAlertsComponent.new(school_group: school_group, limit:, grouped:))
    end

    private

    def group_options
      {
        choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
