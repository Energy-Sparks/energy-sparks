# frozen_string_literal: true

module Admin
  class QuickLinksComponent < ApplicationComponent
    def school_groups
      SchoolGroup.where(default_issues_admin_user: current_user).with_active_schools.order(:name)
    end

    def schools
      School.active
            .joins(:school_group)
            .where(school_group: { default_issues_admin_user_id: current_user.id })
            .select(:id, :name)
            .order(:name)
    end
  end
end
