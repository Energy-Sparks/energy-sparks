# frozen_string_literal: true

module Commercial
  class ContractSchoolSummaryComponent < ApplicationComponent
    def initialize(contract:, table_id: 'contract-school-summary-table', **)
      super(**)
      @contract = contract
      @table_id = table_id
    end

    def render?
      !@contract.contract_holder.is_a?(School)
    end

    private

    def over_licensed?
      @contract.schools.count > @contract.number_of_schools
    end
  end
end
