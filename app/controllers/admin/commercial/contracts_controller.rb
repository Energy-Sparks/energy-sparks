module Admin::Commercial
  class ContractsController < AdminController
    load_and_authorize_resource :contract, class: 'Commercial::Contract'

    def index
      @contracts = Commercial::Contract.all
    end

    def contract_holder_options
      type = params[:type]

      records = case type
                when 'School'      then School.active.order(:name)
                when 'SchoolGroup' then SchoolGroup.order(:name)
                when 'Funder'      then Funder.order(:name)
                else []
                end

      render json: records.map { |r| { id: r.id, name: r.name } }
    end

    def new
      if params[:original_contract_id].present?
        @original = Commercial::Contract.find(params[:original_contract_id])
        @contract = Commercial::Contract.as_renewal(@original)
      elsif params[:contract_holder_id].present?
        contract_holder = case params[:contract_holder_type]
                          when 'School'      then School.find(params[:contract_holder_id])
                          when 'SchoolGroup' then SchoolGroup.find(params[:contract_holder_id])
                          when 'Funder'      then Funder.find(params[:contract_holder_id])
                          end
        @contract = Commercial::Contract.new(contract_holder:)
      else
        @contract = Commercial::Contract.new(contract_holder_type: 'Funder')
      end
    end

    def create
      @contract = Commercial::Contract.build(contract_params.merge(created_by: current_user))
      if @contract.save
        if params[:renew_licences] == '1'
          @original = Commercial::Contract.find(params[:original_contract_id])
          Commercial::Contract.transaction do
            @original.licences.each do |licence|
              Commercial::LicenceManager.new(licence.school).contract_renewed(@contract, licence)
            end
          end
          notice = 'Contract and provisional licences have been created'
        else
          notice = 'Contract has been created'
        end
        redirect_to admin_commercial_contract_path(@contract), notice:
      else
        render :new
      end
    end

    def edit
    end

    # What needs cascading:
    # 1) Status
    #
    # Provisional -> Confirmed
    # Confirmed -> Provisional (unlikely, but possible)
    #
    # Update all licences that are in those states, but not those that are pending or invoiced.
    #
    # 2) Start/End Dates
    #
    # Rewrite the start/end dates for all licences. If Contract
    # If custom, then they don't cascade as not relevant. This might be a case where you want to tweak them.
    def update
      if @contract.update(contract_params.merge(updated_by: current_user))
        redirect_to admin_commercial_contracts_path, notice: 'Contract has been updated'
      else
        render :edit
      end
    end

    def destroy
      if @contract.destroy
        redirect_to(admin_commercial_contracts_path, alert: 'Contract has been deleted')
      else
        redirect_to(admin_commercial_contracts_path, alert: @contract.errors.full_messages.to_sentence)
      end
    end

    private

    def contract_params
      params.require(:contract).permit(
        :agreed_school_price,
        :comments,
        :contract_holder_id,
        :contract_holder_type,
        :end_date,
        :invoice_terms,
        :licence_period,
        :licence_years,
        :name,
        :number_of_schools,
        :product_id,
        :purchase_order_number,
        :start_date,
        :status
      )
    end
  end
end
