module Schools
  class ClusterAdminsController < ApplicationController
    include AlertContactCreator

    load_and_authorize_resource :school

    def new
    end

    def create
      user = User.find_by_email(user_params[:email])
      if user
        user.add_cluster_school(@school)
        user.add_cluster_school(user.school) unless user.school.nil?
        user.role = :school_admin
        if user.save
          create_or_update_alert_contact(@school, user) if auto_create_alert_contact?
        end
        redirect_to school_users_path(@school), notice: 'User added as school admin'
      else
        flash[:alert] = 'User not found'
        render :new
      end
    end

    private

    def user_params
      params.require(:user).permit(:email)
    end
  end
end
