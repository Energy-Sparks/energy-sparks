module Dashboards
  class GroupLearnMoreComponentPreview < ViewComponent::Preview
    # @param slug select :group_options
    def example(slug: nil)
      school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
      user = school_group.users.group_admin.sample
      render(Dashboards::GroupLearnMoreComponent.new(school_group: school_group, user: user))
    end

    private

    def group_options
      {
        choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
