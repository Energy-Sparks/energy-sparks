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
    SchoolGroup.order(:name)
  end
end
