module Commercial
  class LicencesComponent < TemporalRangeComponent
    def initialize(holder: nil, range: :all, show_contract: true, **kwargs)
      @show_contract = show_contract
      super(holder:, range:, association_name: :licences, **kwargs)
    end
  end
end
