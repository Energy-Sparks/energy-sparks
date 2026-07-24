# frozen_string_literal: true

module Commercial
  class ContractSchoolSummaryComponentPreview < ViewComponent::Preview
    # @param id select :contract_options
    def example(id: nil)
      contract = id ? ::Commercial::Contract.find(id) : ::Commercial::Contract.current.sample(1).first

      render Commercial::ContractSchoolSummaryComponent.new(contract:)
    end

    private

    def contract_options
      {
        choices: ::Commercial::Contract.current.by_name.pluck(:name, :id)
      }
    end
  end
end
