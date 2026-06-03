module Dashboards
  class GroupEnergySummaryComponentPreview < ViewComponent::Preview
    # @param slug select :group_options
    # @param show_clusters toggle
    # @param metric select { choices: [usage, co2, cost, change] }
    def example(slug: nil, show_clusters: false, metric: :change)
      school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
      render(Dashboards::GroupEnergySummaryComponent.new(
               school_group: school_group,
               schools: school_group.schools.active,
               fuel_types: school_group.fuel_types,
               metric:,
               show_clusters:
      ))
    end

    private

    def group_options
      {
        choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
