# frozen_string_literal: true

module SchoolGroupAccessControl
  # Rely on CanCan to filter the list of schools to those that can be shown to the current user

  def load_schools
    @schools = @school_group.schools.includes(:configuration).active.accessible_by(current_ability, :show).by_name
  end

  def redirect_unless_authorised
    # no permission on group
    redirect_to map_school_group_path(@school_group) and return if cannot?(:compare, @school_group)
    # no permissions on any current schools in group. Will not redirect if @schools is nil
    redirect_to map_school_group_path(@school_group) and return if @schools && @schools.empty?
  end
end
