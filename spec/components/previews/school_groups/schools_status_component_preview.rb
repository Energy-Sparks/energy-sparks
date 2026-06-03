class SchoolGroups::SchoolsStatusComponentPreview < ViewComponent::Preview
  # @param slug select :group_options
  def default(slug: nil)
    @slug = slug
    schools = school_group.assigned_schools.active
    onboardings = school_group.school_onboardings
    render(SchoolGroups::SchoolsStatusComponent.new(school_group: school_group, schools:, onboardings:))
  end

  private

  def school_group
    @slug ? SchoolGroup.find(@slug) : groups.sample
  end

  def groups
    SchoolGroup.with_active_schools
  end

  def group_options
    {
      choices: groups.by_name.map { |g| [g.name, g.slug] }
    }
  end
end
