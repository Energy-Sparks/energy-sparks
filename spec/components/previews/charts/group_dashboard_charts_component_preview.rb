module Charts
  class GroupDashboardChartsComponentPreview < ViewComponent::Preview
    def default
      render(
        Charts::GroupDashboardChartsComponent.new(school_group: SchoolGroup.find(19))
      )
    end
  end
end
