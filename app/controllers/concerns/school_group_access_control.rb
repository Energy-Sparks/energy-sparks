# frozen_string_literal: true

module SchoolGroupAccessControl
  # Rely on CanCan to filter the list of schools to those that can be shown to the current user

  def filtered_schools
    @school_group.assigned_schools.includes(:configuration).active.accessible_by(current_ability, :show)
  end

  def load_schools
    @schools = filtered_schools.by_name
  end

  def redirect_unless_authorised
    store_location_for(:user, request.fullpath) unless user_signed_in? || @school_group.public?

    # no permission on group
    redirect_to map_school_group_path(@school_group) and return if cannot?(:show, @school_group)
    # no permissions on any current schools in group. Will not redirect if @schools is nil
    redirect_to map_school_group_path(@school_group) and return if @schools && @schools.empty?
  end
end
