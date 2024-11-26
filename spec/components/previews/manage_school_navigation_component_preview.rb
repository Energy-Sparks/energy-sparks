class ManageSchoolNavigationComponentPreview < ViewComponent::Preview
  def with_school_admin(slug: nil)
    school = school(slug)
    current_user = school.users.school_admin.first
    render(ManageSchoolNavigationComponent.new(school: school, current_user: current_user))
  end

  def with_admin(slug: nil)
    school = school(slug)
    current_user = User.admin.first
    render(ManageSchoolNavigationComponent.new(school: school, current_user: current_user))
  end

  private

  def school(slug)
    slug ? School.find(slug) : School.active.sample
  end
end
