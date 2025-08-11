class Scoreboards::GroupSummaryComponentPreview < ViewComponent::Preview
  def example(slug: nil)
    school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
    render(Scoreboards::GroupSummaryComponent.new(school_group: school_group, user: User.admin.first))
  end
end
