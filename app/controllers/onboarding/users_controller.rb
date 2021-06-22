module Onboarding
  class UsersController < BaseController
    def index
      @users = @school_onboarding.school.users.reject {|u| u.id == current_user.id }
    end

    def new
      @user = @school_onboarding.school.users.new(role: :staff)
      respond_to do |format|
        format.html
        format.js
      end
    end

    def create
      @user = @school_onboarding.school.users.build(user_params.merge(school: @school_onboarding.school))
      #Devise::Mailer.confirmation_instructions(@user).deliver
      #@user.send_confirmation_instructions
      @user.skip_confirmation_notification!
      if @user.save
        respond_to do |format|
          format.js { render js: "window.location='#{onboarding_users_path(@school_onboarding)}'" }
        end
        #redirect back to end of onboarding, if :pupil_account_created
      else
        respond_to do |format|
          format.html { render :new }
          format.js { render :new }
        end
      end
    end

    def edit
      #edit user
      #redirect back to end of onboarding, if :pupil_account_created
    end

    def update
      #update user
      #redirect back to end of onboarding, if :pupil_account_created
    end

    def destroy
      @user = @school_onboarding.school.users.find(params[:id]).destroy
      #redirect back to end of onboarding, if :pupil_account_created
      redirect_to onboarding_users_path(@school_onboarding)
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :staff_role_id, :role)
    end
  end
end
