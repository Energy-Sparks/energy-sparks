class ComparisonService
  def initialize(user)
    @user = user
  end

  def list_scoreboards
    if @user.present? && @user.admin?
      return Scoreboard.order(:name).to_a
    end
    scoreboards = Scoreboard.is_public.order(:name).to_a
    if @user.present? && @user.school.present? && @user.school.scoreboard.present?
      scoreboards << @user.school.scoreboard
    end
    scoreboards.uniq
  end

  def list_school_groups
    groups = SchoolGroup.organisation_groups
    groups = @user&.admin? ? groups.or(SchoolGroup.project_groups) : groups.is_public
    groups = groups.with_active_schools.to_a
    groups << @user.school.school_group if @user&.school&.school_group.present?
    groups.uniq.sort_by!(&:name)
  end

  def list_school_types
    School.school_types
  end
end
