class Navigation::ManageGroupComponentPreview < ViewComponent::Preview
  # @param slug select :group_options
  # @param user_type select :user_type_options
  def default(slug: nil, user_type: :admin)
    @slug = slug
    @user_type = user_type
    render(Navigation::ManageGroupComponent.new(school_group: school_group, current_user: current_user))
  end

  private

  def school_group
    @slug ? SchoolGroup.find(@slug) : groups.sample
  end

  def groups
    SchoolGroup.all
  end

  def current_user
    case @user_type
    when :admin then User.admin.first
      # when :school_admin then school.users.school_admin.first
    end
  end

  def user_type_options
    {
      choices: [:admin].map { |t| [t.to_s.humanize, t] }
    }
  end

  def group_options
    {
      choices: groups.by_name.map { |g| [g.name, g.slug] }
    }
  end
end
