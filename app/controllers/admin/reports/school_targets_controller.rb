module Admin
  module Reports
    class SchoolTargetsController < AdminController
      def index
        @currently_active = SchoolTarget.currently_active.count
        @school_targets = SchoolTarget.joins(:school).currently_active.order(name: :asc)
      end
    end
  end
end
