class ComparisonService
  def initialize(user)
    @user = user
  end

  def list_school_groups
    if @user.present? && @user.admin?
      return SchoolGroup.order(:name).to_a
    end
    groups = SchoolGroup.is_public.order(:name).to_a
    if @user.present? && @user.school.present? && @user.school.school_group.present?
        groups << @user.school.school_group
    end
    groups.uniq.sort_by(&:name)
  end

  def list_school_types
    School.school_types
  end
end
