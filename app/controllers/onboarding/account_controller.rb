module Onboarding
  class AccountController < BaseController
    skip_before_action :authenticate_user!, only: [:new, :create]
    before_action :redirect_if_logged_in, only: [:new]
    before_action only: [:new, :create] do
      redirect_if_event(:onboarding_user_created, new_onboarding_school_details_path(@school_onboarding))
    end

    def new
      @user = User.new(email: @school_onboarding.contact_email)
    end

    def create
      @user = User.new_school_onboarding(user_params)
      if @user.save
        @school_onboarding.update!(created_user: @user)
        @school_onboarding.events.create!(event: :onboarding_user_created)
        sign_in(@user, scope: :user)
        redirect_to new_onboarding_school_details_path(@school_onboarding)
      else
        render :new
      end
    end

    def edit
    end

    def update
      if current_user.update(user_params.reject {|key, value| key =~ /password/ && value.blank?})
        @school_onboarding.events.create!(event: :onboarding_user_updated)
        bypass_sign_in(current_user)
        redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'your-account')
      else
        render :edit
      end
    end

  private

    def redirect_if_logged_in
      if user_signed_in? && @school_onboarding.created_user.blank?
        redirect_to new_onboarding_clustering_path(@school_onboarding)
      end
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :staff_role_id)
    end
  end
end
