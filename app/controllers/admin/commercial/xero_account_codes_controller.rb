# frozen_string_literal: true

module Admin
  module Commercial
    class XeroAccountCodesController < AdminController
      load_and_authorize_resource :xero_account_code, class: 'Commercial::XeroAccountCode'

      def index
        @xero_account_codes = ::Commercial::XeroAccountCode.all.by_code
      end

      def create
        return unless @xero_account_code.save

        redirect_to admin_commercial_xero_account_codes_path, notice: 'Code was successfully created'
      end

      def update
        if @xero_account_code.update(xero_account_code_params)
          redirect_to admin_commercial_xero_account_codes_path, notice: 'Code was successfully updated'
        else
          render :edit
        end
      end

      def destroy
        if @xero_account_code.destroy
          redirect_to(admin_commercial_xero_account_codes_path, notice: 'Code was successfully deleted')
        else
          redirect_to(admin_commercial_products_path, alert: @xero_account_code.errors.full_messages.to_sentence)
        end
      end

      private

      def xero_account_code_params
        params.expect(xero_account_code: %i[code label])
      end
    end
  end
end
