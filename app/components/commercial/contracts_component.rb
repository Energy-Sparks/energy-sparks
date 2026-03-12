module Commercial
  class ContractsComponent < ApplicationComponent
    renders_one :header, ->(**kwargs) do
      Elements::HeaderComponent.new(**{ level: 2 }.merge(kwargs))
    end

    def initialize(contracts:, show_contract_holder: true, show_actions: true, **kwargs)
      super(**kwargs)
      @contracts = contracts
      @show_contract_holder = show_contract_holder
      @show_actions = show_actions
    end
  end
end
