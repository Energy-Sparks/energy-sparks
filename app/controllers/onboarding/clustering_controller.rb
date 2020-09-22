module Onboarding
  class ClusteringController < BaseController
    before_action only: [:new, :create] do
      redirect_if_event(:onboarding_user_created, new_onboarding_school_details_path(@school_onboarding))
    end

    def new
    end

    def create
      @school_onboarding.update!(created_user: current_user)
      @school_onboarding.events.create!(event: :onboarding_user_created)
      redirect_to new_onboarding_school_details_path(@school_onboarding)
    end
  end
end
