# frozen_string_literal: true

module SchoolGroupAccessControl
  def redirect_unless_authorised
    # no permission on group
    redirect_to map_school_group_path(@school_group) and return if cannot?(:compare, @school_group)
    # no permissions on any current schools in group
    redirect_to map_school_group_path(@school_group) and return if @schools&.empty?
  end
end
