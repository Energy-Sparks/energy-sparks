class Scoreboards::GroupSummaryComponentPreview < ViewComponent::Preview
  # @param slug select :group_options
  def example(slug: nil)
    school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.sample
    render(Scoreboards::GroupSummaryComponent.new(school_group: school_group, user: User.admin.first))
  end

  private

  def group_options
    {
      choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
    }
  end
end
