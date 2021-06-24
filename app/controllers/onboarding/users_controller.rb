module Onboarding
  class UsersController < BaseController
    include OnboardingHelper

    def index
      @users = @school_onboarding.school.users.reject {|u| u.id == current_user.id || u.pupil? }
    end

    def new
      @user = @school_onboarding.school.users.new(role: :staff)
      authorize! :create, @user
      respond_to do |format|
        format.html
        format.js
      end
    end

    def create
      @user = @school_onboarding.school.users.build(user_params.merge(school: @school_onboarding.school))
      @user.skip_confirmation_notification!
      if @user.save
        change_user_subscribed_to_newsletter(@school_onboarding, @user, newsletter_params[:subscribe_to_newsletter])
        respond_to do |format|
          format.html { redirect_to onboarding_users_path(@school_onboarding) }
          format.js { render js: "window.location='#{onboarding_users_path(@school_onboarding)}'" }
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.js { render :new }
        end
      end
    end

    def edit
      @user = @school_onboarding.school.users.find(params[:id])
      authorize! :edit, @user
      respond_to do |format|
        format.html
        format.js
      end
    end

    def update
      @user = @school_onboarding.school.users.find(params[:id])
      authorize! :edit, @user
      if @user.update(user_params)
        change_user_subscribed_to_newsletter(@school_onboarding, @user, newsletter_params[:subscribe_to_newsletter])
        respond_to do |format|
          format.html { redirect_to onboarding_users_path(@school_onboarding) }
          format.js { render js: "window.location='#{onboarding_users_path(@school_onboarding)}'" }
        end
      else
        respond_to do |format|
          format.html { render :edit }
          format.js { render :edit }
        end
      end
    end

    def destroy
      @user = @school_onboarding.school.users.find(params[:id]).destroy
      redirect_to onboarding_users_path(@school_onboarding)
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :staff_role_id, :role)
    end

    def newsletter_params
      params.require(:newsletter).permit(:subscribe_to_newsletter).transform_values {|v| ActiveModel::Type::Boolean.new.cast(v)}
    end
  end
end
