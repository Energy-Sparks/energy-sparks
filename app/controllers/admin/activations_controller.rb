module Admin
  class ActivationsController < AdminController
    def index
      @school_groups = SchoolGroup.organisation_groups.by_name.select(&:has_schools_awaiting_activation?)
    end
  end
end
