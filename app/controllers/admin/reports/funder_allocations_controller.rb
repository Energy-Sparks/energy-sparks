# frozen_string_literal: true

module Admin
  module Reports
    class FunderAllocationsController < AdminController
      def show
        @funders_visible = Funder.funded_school_counts(visible: true, data_enabled: false)
        @funders_visible_and_enabled = Funder.funded_school_counts(visible: true, data_enabled: true)
        @unfunded_visible = School.visible.unfunded.count
        @unfunded_visible_and_enabled = School.visible.data_enabled.unfunded.count
      end

      def deliver
        FunderAllocationReportJob.perform_later(to: current_user.email)
        redirect_back fallback_location: admin_reports_funder_allocations_path,
                      notice: "Funder allocation report has been sent to #{current_user.email}"
      end
    end
  end
end
