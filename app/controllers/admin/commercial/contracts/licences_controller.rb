module Admin
  module Commercial
    module Contracts
      class LicencesController < AdminController
        load_and_authorize_resource :contract,
          class: 'Commercial::Contract'

        def edit
          contracted_schools = @contract.licences.map(&:school_id)
          @additional_schools = if @contract.contract_holder.is_a?(SchoolGroup)
                                  scope = @contract.contract_holder.assigned_schools.where(
                                    default_contract_holder: @contract.contract_holder
                                  )
                                  scope.where.not(id: contracted_schools).by_name
                                else
                                  []
                                end
        end

        def update
          if @contract.update(contract_params)
            redirect_to edit_admin_commercial_contract_licences_path(@contract), notice: 'Licences updated'
          else
            render :edit
          end
        end

        def create_licence
          @contract = ::Commercial::Contract.find(params[:contract_id])
          @school = School.find(params[:school_id])
          @licence = ::Commercial::LicenceManager.new(@school).school_onboarded(@contract)

          respond_to do |format|
            format.js
            format.html { redirect_to edit_admin_commercial_contract_path(@contract) }
          end
        end

        private

        def contract_params
          params.require(:commercial_contract).permit(
            licences_attributes: [
              :_destroy,
              :id, :start_date, :end_date, :status,
              :school_specific_price, :invoice_reference, :comments
            ]
          )
        end
      end
    end
  end
end
