# frozen_string_literal: true

module Admin
  module Dashboard
    class InterventionsController < Admin::Reports::InterventionsController
      include AdminDashboard

      before_action :set_user

      def index
        @observations = Observation.joins(school: :school_group)
                                   .where(school_group: { default_issues_admin_user_id: @dashboard_user })
                                   .where(created_at: 1.year.ago..)
                                   .includes(:school,
                                             :intervention_type,
                                             :created_by,
                                             school: :school_group,
                                             rich_text_description: { embeds_attachments: :blob })
                                   .intervention
                                   .order(created_at: :desc)
        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Interventions' }
                          ])
      end
    end
  end
end
