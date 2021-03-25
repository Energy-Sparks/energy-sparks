module Admin
  module Schools
    class ConsentRequestsController < AdminController
      load_and_authorize_resource :school

      def new
        service = ::Schools::ConsentRequestService.new(@school)
        @users = service.users
      end

      def create
        users = @school.users.where(id: params[:consent_request]["user_ids"])
        if users.any?
          service = ::Schools::ConsentRequestService.new(@school)
          service.request_consent!(users)
          redirect_to admin_meter_reviews_path, notice: "Consent has been requested"
        else
          redirect_to new_admin_school_consent_request_path(@school), alert: "You must select at least one user."
        end
      end

      private

      def consent_request_params
        params.require(:consent_request).permit(:user_ids)
      end
    end
  end
end
