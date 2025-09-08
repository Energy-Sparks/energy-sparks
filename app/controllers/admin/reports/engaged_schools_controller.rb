# frozen_string_literal: true

module Admin
  module Reports
    class EngagedSchoolsController < AdminController
      def index
        @engaged_schools_count = ::Schools::EngagedSchoolService.engaged_schools_count
        @visible_schools = School.visible.count
        @percentage = percentage_engaged
        return unless request.post?

        EngagedSchoolsReportJob.perform_later(current_user.email, params[:previous], params[:school_group_id])
        redirect_back fallback_location: admin_reports_engaged_schools_path,
                      notice: "Report sent to #{current_user.email}"
      end

      private

      def percentage_engaged
        format('%.2f', @engaged_schools_count / @visible_schools.to_f * 100)
      end
    end
  end
end
