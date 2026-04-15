module Admin
  class ActivationsController < AdminController
    def index
      @school_groups = if @dashboard_user
                         SchoolGroup.organisation_groups.by_name.where(default_issues_admin_user: @dashboard_user)
                       else
                         SchoolGroup.organisation_groups.by_name
                       end
      @school_groups = @school_groups.select(&:has_schools_awaiting_activation?)
    end
  end
end
