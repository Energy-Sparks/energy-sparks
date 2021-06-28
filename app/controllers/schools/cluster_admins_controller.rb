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
        user.save!
        redirect_to school_users_path(@school), notice: "User added as school admin"
      else
        flash[:alert] = "User not found"
        render :new
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :auto_create_alert_contact)
    end
  end
end
