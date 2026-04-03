module Commercial
  class LicencesComponent < ApplicationComponent
    renders_one :header, ->(**kwargs) do
      Elements::HeaderComponent.new(**{ level: 2 }.merge(kwargs))
    end

    def initialize(licences:, show_contract: true, show_actions: true, show_renewal_data: false, **kwargs)
      super(**kwargs)
      @licences = licences
      @show_actions = show_actions
      @show_contract = show_contract
      @show_renewal_data = show_renewal_data
    end
  end
end
