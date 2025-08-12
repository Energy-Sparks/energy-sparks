module Dashboards
  class GroupInsightsComponentPreview < ViewComponent::Preview
    def example(slug: nil)
      school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
      user = User.group_admin.last
      component = Dashboards::GroupInsightsComponent.new(school_group: school_group, user: user)
      render(component)
    end

    private

    def group_options
      {
        choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
