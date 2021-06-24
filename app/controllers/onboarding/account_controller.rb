module Onboarding
  class AccountController < BaseController
    include OnboardingHelper

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
        @school_onboarding.events.create!(event: :privacy_policy_agreed)
        sign_in(@user, scope: :user)
        change_user_subscribed_to_newsletter(@school_onboarding, @user, newsletter_params[:subscribe_to_newsletter])
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
        change_user_subscribed_to_newsletter(@school_onboarding, current_user, newsletter_params[:subscribe_to_newsletter])
        bypass_sign_in(current_user)
        redirect_to new_onboarding_completion_path(@school_onboarding)
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

    def newsletter_params
      params.require(:newsletter).permit(:subscribe_to_newsletter).transform_values {|v| ActiveModel::Type::Boolean.new.cast(v)}
    end
  end
end
