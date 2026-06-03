module Onboarding
  class AccountController < BaseController
    include NewsletterSubscriber

    skip_before_action :authenticate_user!, only: [:new, :create]
    before_action :redirect_if_logged_in, only: [:new]
    before_action :set_email_types

    before_action only: [:new, :create] do
      redirect_if_event(:onboarding_user_created, new_onboarding_school_details_path(@school_onboarding))
    end

    def new
      @user = User.new(email: @school_onboarding.contact_email)
      @interests = default_interests(@user)
    end

    def create
      @user = User.new_school_onboarding(user_params)
      if @user.terms_accepted && @user.save
        @school_onboarding.update!(created_user: @user)
        @school_onboarding.events.create!(event: :onboarding_user_created)
        @school_onboarding.events.create!(event: :privacy_policy_agreed)
        sign_in(@user, scope: :user)
        subscribe_newsletter(@user, params.permit(interests: {}))
        redirect_to new_onboarding_school_details_path(@school_onboarding)
      else
        @interests = interests_from_params
        render :new
      end
    end

    def edit
      audience_manager.list # load to ensure config is set
      @interests = user_interests(current_user)
    end

    def update
      if current_user.update(user_params.reject {|key, value| key =~ /password/ && value.blank?})
        @school_onboarding.events.create!(event: :onboarding_user_updated)
        subscribe_newsletter(current_user, params.permit(interests: {}))
        bypass_sign_in(current_user)
        redirect_to new_onboarding_completion_path(@school_onboarding)
      else
        @interests = user_interests(current_user)
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
      params.require(:user).permit(
        :email,
        :name,
        :password,
        :password_confirmation,
        :preferred_locale,
        :staff_role_id,
        :terms_accepted)
    end
  end
end
