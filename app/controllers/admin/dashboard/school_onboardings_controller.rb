# frozen_string_literal: true

module Admin
  module Dashboard
    class SchoolOnboardingsController < Admin::SchoolOnboardingsController
      include AdminDashboard

      before_action :set_user

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Onboardings' }
                          ])
      end

      def completed
        @days = 60
        @pagy, @records = pagy(
          @completed_schools = @school_onboardings.completed_in_last_x_days(@days)
                                                  .joins(:school_group)
                                                  .where(school_group: { default_issues_admin_user: @dashboard_user })
                                                  .includes(:school, school: :school_group)
                                                  .order(updated_at: :desc)
        )
      end
    end
  end
end
