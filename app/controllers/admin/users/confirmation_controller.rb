module Admin
  module Users
    class ConfirmationController < AdminController
      load_and_authorize_resource :user

      def create
        unless @user.confirmed?
          @user.send_confirmation_instructions
        end
        if params[:school] && @user.school.present?
          redirect_to school_users_path(@user.school), notice: "Confirmation email sent"
        else
          redirect_to admin_users_path, notice: "Confirmation email sent"
        end
      end
    end
  end
end
