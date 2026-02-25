# frozen_string_literal: true

class DashboardInsightsComponentPreview < ViewComponent::Preview
  def default(slug: nil)
    school = slug ? School.find(slug) : SchoolTarget.currently_active.sample.school
    render(DashboardInsightsComponent.new(school:))
  end
end
