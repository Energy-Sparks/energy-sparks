# frozen_string_literal: true

module Admin
  module Schools
    class BillRequestsController < AdminController
      load_and_authorize_resource :school

      def new
        service = ::Schools::BillRequestService.new(@school)
        @users = service.users
        @meters = @school.meters.unreviewed_dcc_meter
      end

      def create
        users = User.where(id: params[:bill_request]['user_ids'])
        if users.any?
          meters = @school.meters.where(id: params[:bill_request]['meter_ids'])
          service = ::Schools::BillRequestService.new(@school)
          service.request_documentation!(users, meters)
          redirect_back fallback_location: admin_meter_reviews_path, notice: 'Bill has been requested'
        else
          redirect_to new_admin_school_bill_request_path(@school), alert: 'You must select at least one user.'
        end
      end

      def clear
        @school.update!(bill_requested: false)
        redirect_back fallback_location: admin_meter_reviews_path, notice: 'Cleared bill request'
      end

      private

      def bill_request_params
        params.require(:bill_request).permit(:meter_ids, :user_ids)
      end
    end
  end
end
