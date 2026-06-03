# frozen_string_literal: true

module Admin
  module Users
    class ConfirmationController < AdminController
      load_and_authorize_resource :user

      def create
        @user.send_confirmation_instructions unless @user.confirmed?
        redirect_to admin_users_path, notice: 'Confirmation email sent'
      end
    end
  end
end
