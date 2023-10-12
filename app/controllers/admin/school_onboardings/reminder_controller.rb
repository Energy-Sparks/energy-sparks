module Admin
  module SchoolOnboardings
    class ReminderController < AdminController
      load_and_authorize_resource :school_onboarding, find_by: :uuid

      def create
        Onboarding::ReminderMailer.deliver(school_onboardings: [@school_onboarding])
        redirect_to admin_school_onboardings_path(anchor: @school_onboarding.page_anchor), notice: "Reminder sent to #{@school_onboarding.school_name}"
      end
    end
  end
end
