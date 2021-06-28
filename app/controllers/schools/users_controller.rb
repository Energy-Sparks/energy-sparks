module Schools
  class UsersController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :user, through: :school, except: :destroy


    def index
      authorize! :manage_users, @school
      @school_admins = (@users.school_admin + @school.cluster_users).uniq
      @staff = @users.staff
      @pupils = @users.pupil
    end

    def destroy
      authorize! :manage_users, @school
      #extract out into a school method, so we can use this in the school_admin controller too
      @user = @school.users.find_by_id(params[:id])
      if @user.nil?
        @user = @school.cluster_users.find_by_id(params[:id])
      end
      if @user.has_other_schools?
        @user.cluster_schools.delete(@school)
        #also remove alert contacts
      else
        @user.destroy
      end
      redirect_back fallback_location: school_users_path(@school)
    end
  end
end
