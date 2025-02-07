module Admin
  module Reports
    class MailchimpStatusController < AdminController
      def index
        @user_statuses = User.mailchimp_roles.group(:mailchimp_status).count
        @pending = User.mailchimp_update_required.mailchimp_roles.count
      end
    end
  end
end
