module Commercial
  class ContractsComponent < TemporalRangeComponent
    def initialize(holder: nil, range: :all, **kwargs)
      super(holder:, range:, association_name: :contracts, **kwargs)
    end
  end
end
