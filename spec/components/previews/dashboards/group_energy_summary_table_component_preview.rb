module Dashboards
  class GroupEnergySummaryTableComponentPreview < ViewComponent::Preview
    # @param slug select :group_options
    # @param show_clusters toggle
    # @param fuel_type select { choices: [electricity, gas, storage_heaters] }
    # @param metric select { choices: [usage, co2, cost, change] }
    def example(slug: nil, metric: :change, show_clusters: false, fuel_type: :electricity)
      school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
      render(
        Dashboards::GroupEnergySummaryTableComponent.new(
          school_group: school_group,
          schools: school_group.schools.active,
          fuel_type:,
          metric:,
          show_clusters:,
          path: school_group_advice_path(school_group)
        )
      )
    end

    private

    def group_options
      {
        choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
