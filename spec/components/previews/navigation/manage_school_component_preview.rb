class Navigation::ManageSchoolComponentPreview < ViewComponent::Preview
  # @param slug select :school_options
  # @param user_type select :user_type_options
  def default(slug: nil, user_type: :admin)
    @slug = slug
    @user_type = user_type
    render(Navigation::ManageSchoolComponent.new(school: school, current_user: current_user))
  end

  private

  def school
    @slug ? School.find(@slug) : schools_with_school_admin.sample
  end

  def schools_with_school_admin
    School.active.joins(:users).merge(User.school_admin).distinct
  end

  def current_user
    case @user_type
    when :admin        then User.admin.first
    when :school_admin then school.users.school_admin.first
    end
  end

  def user_type_options
    {
      choices: [:admin, :school_admin].map { |t| [t.to_s.humanize, t] }
    }
  end

  def school_options
    {
      choices: schools_with_school_admin.by_name.map { |g| [g.name, g.slug] }
    }
  end
end
