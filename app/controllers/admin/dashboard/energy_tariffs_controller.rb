# frozen_string_literal: true

module Admin
  module Dashboard
    class EnergyTariffsController < Admin::Reports::EnergyTariffsController
      include AdminDashboard

      before_action :set_user

      def index
        super
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Energy Tariffs' }
                          ])
      end

      private

      def school_groups
        SchoolGroup.organisation_groups
                   .where(default_issues_admin_user: @dashboard_user)
                   .with_visible_schools
                   .order(:name)
      end
    end
  end
end
