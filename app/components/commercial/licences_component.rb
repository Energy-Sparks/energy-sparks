# frozen_string_literal: true

module Commercial
  class LicencesComponent < ApplicationComponent
    renders_one :header, lambda { |**kwargs|
      Elements::HeaderComponent.new(level: 2, **kwargs)
    }

    # rubocop:disable Metrics/ParameterLists
    def initialize(licences:,
                   show_contract: true,
                   show_actions: true,
                   show_renewal_data: false,
                   show_contract_holder: true, **)
      super(**)
      @licences = licences
      @show_actions = show_actions
      @show_contract = show_contract
      @show_renewal_data = show_renewal_data
      @show_contract_holder = show_contract_holder
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
