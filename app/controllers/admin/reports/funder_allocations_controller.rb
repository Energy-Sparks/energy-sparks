# frozen_string_literal: true

module Admin
  module Reports
    class FunderAllocationsController < AdminController
      def show
        @funders_visible = Funder.funded_school_counts(visible: true, data_enabled: false)
        @funders_visible_and_enabled = Funder.funded_school_counts(visible: true, data_enabled: true)
        @onboarding = Funder.joins('LEFT JOIN school_onboardings ON funders.id = school_onboardings.funder_id ' \
                                   'AND school_onboardings.school_id IS NULL')
                            .group(:name).count('school_onboardings.id')
        @unfunded_visible = School.visible.unfunded.count
        @unfunded_visible_and_enabled = School.visible.data_enabled.unfunded.count
        @unfunded_onboarding = SchoolOnboarding.where(funder: nil, school: nil).count
      end

      def deliver
        FunderAllocationReportJob.perform_later(to: current_user.email)
        redirect_back fallback_location: admin_reports_funder_allocations_path,
                      notice: "Funder allocation report has been sent to #{current_user.email}"
      end
    end
  end
end
