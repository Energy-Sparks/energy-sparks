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

    def create
      authorize! :manage_users, @school
      @user = User.new(user_params.merge(school: @school))
      if @user.save
        redirect_to school_users_path(@school)
      else
        render :new
      end
    end

    def edit
      @user = @school.find_user_or_cluster_user_by_id(params[:id])
      authorize! :edit, @user
    end

    def update
      @user = @school.find_user_or_cluster_user_by_id(params[:id])
      authorize! :update, @user
      if @user.update(user_params)
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
        @user.cluster_schools.delete(@school)
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

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.manage_users') }]
    end

    def user_params
      params.require(:user).permit(:name, :email, :staff_role_id, :role, :preferred_locale)
    end
  end
end
