module Admin
    class ActivationsController < AdminController
      def index
        @school_groups = SchoolGroup.by_name.select(&:has_schools_awaiting_activation?)
      end
    end
end
