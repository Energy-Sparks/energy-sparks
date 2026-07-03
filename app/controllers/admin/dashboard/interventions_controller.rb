# frozen_string_literal: true

module Admin
  module Dashboard
    class InterventionsController < Admin::Reports::InterventionsController
      include AdminDashboard

      before_action :set_user

      def index
        super
        @observations = @observations.for_admin(@dashboard_user)

        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Interventions' }
                          ])
      end
    end
  end
end
