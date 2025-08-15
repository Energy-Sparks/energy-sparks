module Dashboards
  class GroupSavingsPromptComponentPreview < ViewComponent::Preview
    # @param slug select :group_options
    # @param metric select { choices: [kwh, gbp, co2] }
    def example(slug: nil, metric: :kwh)
      school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
      render(Dashboards::GroupSavingsPromptComponent.new(school_group: school_group, schools: school_group.schools.active, metric: metric))
    end

    private

    def group_options
      {
        choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
