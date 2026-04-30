# frozen_string_literal: true

module Admin
  module Dashboard
    class PupilNumberUpdatesController < Admin::Reports::PupilNumberUpdatesController
      include AdminDashboard

      before_action :set_user

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Pupil number updates' }
                          ])
      end
    end
  end
end
