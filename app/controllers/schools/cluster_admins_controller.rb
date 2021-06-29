module Schools
  class ClusterAdminsController < ApplicationController
    include AlertContactCreator
    include NewsletterSubscriber

    load_and_authorize_resource :school

    def new
    end

    def create
      user = User.find_by_email(user_params[:email])
      if user
        user.add_cluster_school(@school)
        if user.save
          create_alert_contact(@school, user) if auto_create_alert_contact?
        end
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
