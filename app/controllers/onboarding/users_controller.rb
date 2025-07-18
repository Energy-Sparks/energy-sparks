# frozen_string_literal: true

module Onboarding
  class UsersController < BaseController
    def index
      @users = @school_onboarding.school.users.reject { |u| u.id == current_user.id || u.pupil? }
    end

    def new
      @user = @school_onboarding.school.users.new(role: :staff)
      authorize! :create, @user
      respond_to do |format|
        format.html
        format.js
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

    def create
      @user = @school_onboarding.school.users
                                .build(user_params.merge(school: @school_onboarding.school, created_by: current_user))
      @user.skip_confirmation_notification!
      if @user.save
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

    def update
      @user = @school_onboarding.school.users.find(params[:id])
      authorize! :edit, @user
      if @user.update(user_params)
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
      params.require(:user).permit(:name, :email, :staff_role_id, :role, :preferred_locale)
    end
  end
end
