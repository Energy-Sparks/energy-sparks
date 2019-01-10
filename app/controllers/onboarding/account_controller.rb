module Onboarding
  class AccountController < BaseController
    skip_before_action :authenticate_user!
    before_action do
      redirect_if_event(:onboarding_user_created, new_onboarding_school_details_path(@school_onboarding))
    end

    def new
      @user = User.new(email: @school_onboarding.contact_email)
    end

    def create
      @user = User.new(
        user_params.merge(role: 'school_onboarding')
      )
      if @user.save
        @school_onboarding.update!(created_user: @user)
        @school_onboarding.events.create!(event: :onboarding_user_created)
        sign_in(@user, scope: :user)
        redirect_to new_onboarding_school_details_path(@school_onboarding)
      else
        render :new
      end
    end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end
end
