module Commercial
  class LicencesComponent < TemporalRangeComponent
    def initialize(holder: nil, range: :all, **kwargs)
      super(holder:, range:, association_name: :licences, **kwargs)
    end
  end
end
