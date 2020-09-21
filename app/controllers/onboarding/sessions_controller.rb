module Onboarding
  class SessionsController < BaseController
    def destroy
      sign_out(current_user)
      redirect_to new_onboarding_account_path(@school_onboarding)
    end
  end
end
