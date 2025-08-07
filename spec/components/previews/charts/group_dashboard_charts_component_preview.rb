module Charts
  class GroupDashboardChartsComponentPreview < ViewComponent::Preview
    def example(slug: nil, title: 'Energy use')
      school_group = school_group(slug)
      component = Charts::GroupDashboardChartsComponent.new(school_group:)
      component.with_title do
        "<h1>#{title} (#{school_group.name})</h1>".html_safe
      end
      render(component)
    end

    private

    def school_group(slug)
      return SchoolGroup.with_visible_schools.sample unless slug.present?
      SchoolGroup.find(slug)
    end
  end
end
