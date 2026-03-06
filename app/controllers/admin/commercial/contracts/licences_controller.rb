module Admin
  module Commercial
    module Contracts
      class LicencesController < AdminController
        load_and_authorize_resource :contract,
          class: 'Commercial::Contract'

        before_action :set_licences, only: [:edit, :update]

        def edit
        end

        def update
          if @contract.update(contract_params)
            redirect_to edit_admin_commercial_contract_licences_path(@contract), notice: 'Updated'
          else
            render :edit
          end
        end

        private

        def set_licences
          @licences = @contract.licences.joins(:school).order(school: { name: :asc })
        end

        def contract_params
          params.require(:commercial_contract).permit(
            licences_attributes: [
              :id, :start_date, :end_date, :status,
              :school_specific_price, :invoice_reference, :comments
            ]
          )
        end
      end
    end
  end
end
