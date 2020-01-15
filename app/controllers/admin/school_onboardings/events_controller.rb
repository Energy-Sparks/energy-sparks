module Admin
  module SchoolOnboardings
    class EventsController < AdminController
      load_and_authorize_resource :school_onboarding, find_by: :uuid

      def create
        @school_onboarding.events.create!(event: params[:event])
        redirect_to admin_school_onboardings_path
      end
    end
  end
end
