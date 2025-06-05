# frozen_string_literal: true

module Schools
  class UsersController < ApplicationController
    include AlertContactCreator

    load_and_authorize_resource :school

    before_action :set_breadcrumbs

    def index
      authorize! :manage_users, @school
      @users = @school.users
      @school_admins = @school.all_school_admins.uniq
      @staff = @users.staff
      @pupils = @users.pupil
    end

    def new
      authorize! :manage_users, @school
      @user = @school.users.new(role: params[:role])
      authorize! :create, @user
    end

    def edit
      @user = @school.find_user_or_cluster_user_by_id(params[:id])
      authorize! :edit, @user
    end

    def create
      authorize! :manage_users, @school
      @user = User.new(user_params.merge(school: @school, created_by: current_user))
      if @user.role == 'school_admin'
        redirect, notice = add_school_admin
      else
        redirect = @user.save
      end
      if redirect
        redirect_to school_users_path(@school), notice:
      else
        render :new
      end
    end

    def update
      @user = @school.find_user_or_cluster_user_by_id(params[:id])
      authorize! :update, @user
      @user.assign_attributes(user_params)
      if @user.save(context: :form_update)
        update_alert_contact(@school, @user)
        redirect_to school_users_path(@school)
      else
        render :edit
      end
    end

    def destroy
      authorize! :manage_users, @school
      @user = @school.find_user_or_cluster_user_by_id(params[:id])
      if @user.has_other_schools?
        @user.remove_school(@school)
        @user.contacts.where(school: @school).delete_all
      else
        @user.destroy
      end
      redirect_back fallback_location: school_users_path(@school)
    end

    def make_school_admin
      @user = @school.find_user_or_cluster_user_by_id(params[:id])
      authorize! :update, @user
      @user.update(role: :school_admin)
      redirect_to school_users_path(@school)
    end

    def unlock
      user = @school.find_user_or_cluster_user_by_id(params[:id])
      authorize! :manage, :admin_functions
      user.unlock_access!
      redirect_to school_users_path(@school), notice: "User '#{user.email}' was successfully unlocked."
    end

    def lock
      user = @school.find_user_or_cluster_user_by_id(params[:id])
      authorize! :manage, :admin_functions
      user.lock_access!(send_instructions: false)
      redirect_to school_users_path(@school), notice: "User '#{user.email}' was successfully locked."
    end

    def resend_confirmation
      authorize! :manage_users, @school
      user = @school.find_user_or_cluster_user_by_id(params[:id])
      user.send_confirmation_instructions unless user.confirmed?
      redirect_to school_users_path(@school), notice: 'Confirmation email sent'
    end

    private

    def add_school_admin
      @user.valid? # to run validations
      redirect = false
      if @user.errors.where(:email).filter { |error| error.type != :taken }.empty? && !params.key?(:new_user_form)
        existing_user = User.find_by(email: @user.email)
        if existing_user&.role == 'group_admin'
          redirect = true
          notice = "As a group admin for #{existing_user.school_group.name}, this user is already able to administer " \
                      'this school'
        elsif existing_user.present?
          existing_user.add_cluster_school(@school)
          existing_user.add_cluster_school(existing_user.school) unless existing_user.school.nil?
          existing_user.role = :school_admin
          @user = existing_user
          redirect = @user.save
          notice = 'Added user as a school admin' if redirect
        else
          @user.errors.clear
          @new_school_admin = true
        end
      else
        redirect = @user.save
      end
      [redirect, notice]
    end

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.manage_users') }]
    end

    def user_params
      params.require(:user).permit(:name, :email, :staff_role_id, :role, :preferred_locale)
    end
  end
end
