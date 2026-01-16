module Admin::Commercial
  class ContractsController < AdminController
    load_and_authorize_resource :contract, class: 'Commercial::Contract'

    def index
      # FIXME ordering, scope
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
      @contract = Commercial::Contract.new(contract_holder_type: 'Funder')
    end

    def create
      @contract = Commercial::Contract.build(contract_params.merge(created_by: current_user))
      if @contract.save
        redirect_to admin_commercial_contracts_path, notice: 'Contract has been created'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @contract.update(contract_params.merge(updated_by: current_user))
        redirect_to admin_commercial_contracts_path, notice: 'Contract has been updated'
      else
        render :edit
      end
    end

    def destroy
      path = admin_commercial_contracts_path
      if @contract.licences.any?
        redirect_to(path, notice: 'Cannot delete a contract with licences') and return
      end
      @contract.destroy
      redirect_to(path, notice: 'Contract has been deleted')
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
        :name,
        :number_of_schools,
        :product_id,
        :start_date,
        :status
      )
    end
  end
end
