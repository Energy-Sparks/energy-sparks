module Admin
  module Commercial
    class ContractHolderContractsController < AdminController
      load_and_authorize_resource :funder, instance_name: 'contract_holder'
      load_and_authorize_resource :school_group, instance_name: 'contract_holder'
      load_and_authorize_resource :school, instance_name: 'contract_holder'

      def index
        @contracts = @contract_holder.contracts.by_start_date
      end
    end
  end
end
