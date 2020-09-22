module Onboarding
  class SessionsController < BaseController
    def new
      store_location_for(:user, new_onboarding_clustering_path(@school_onboarding))
      redirect_to new_user_session_path
    end

    def destroy
      sign_out(current_user)
      redirect_to new_onboarding_account_path(@school_onboarding)
    end
  end
end
