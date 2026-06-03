# frozen_string_literal: true

module Admin
  module Dashboard
    class ActivitiesController < Admin::Reports::ActivitiesController
      include AdminDashboard

      before_action :set_user

      def index
        @activities = Activity.joins(school: :school_group)
                              .where(school_group: { default_issues_admin_user_id: @dashboard_user })
                              .where(created_at: 1.year.ago..)
                              .includes(:observations,
                                        :school,
                                        :activity_type,
                                        observations: :created_by,
                                        school: :school_group,
                                        rich_text_description: { embeds_attachments: :blob })
                              .order(created_at: :desc)

        build_breadcrumbs([
                            { name: @dashboard_user.display_name, href: admin_dashboard_path(@dashboard_user) },
                            { name: 'Activities' }
                          ])
      end
    end
  end
end
