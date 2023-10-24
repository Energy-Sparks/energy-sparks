module Admin
  module Reports
    class RecentAuditsController < AdminController
      def index
        @recent_audits = Audit.all.order(created_at: :desc)
      end
    end
  end
end
