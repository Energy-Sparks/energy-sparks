module Schools
  class UsersController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user, through: :school


    def index
      authorize! :manage_users, @school
      @school_admins = (@users.school_admin + @school.cluster_users).uniq
      @staff = @users.staff
      @pupils = @users.pupil
    end

    def destroy
      @user.destroy
      redirect_back fallback_location: school_users_path(@school)
    end
  end
end
