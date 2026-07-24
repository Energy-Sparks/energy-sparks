# frozen_string_literal: true

module Admin
  module Commercial
    class ContractHoldersController < AdminController
      def index
        @contract_holder_summaries = ::Commercial::Contract.current_contract_holder_summaries
      end
    end
  end
end
