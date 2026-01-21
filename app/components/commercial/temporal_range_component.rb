module Commercial
  class TemporalRangeComponent < ApplicationComponent
    RANGES = %i[all current historical future].freeze

    def initialize(holder:, association_name:, range: :all, show_actions: true, **kwargs)
      super(**kwargs)
      @holder = holder
      @association_name = association_name.to_sym
      @range = normalize_range(range)
      @show_actions = show_actions
    end

    def render?
      associations.any?
    end

    def associations
      scoped_source.public_send(@range)
    end

    private

    def scoped_source
      @holder ? base_scope : model_class
    end

    def base_scope
      @holder.public_send(@association_name)
    end

    def model_class
      Commercial.const_get(@association_name.to_s.classify)
    end

    def normalize_range(range)
      sym = range.to_sym
      return sym if self.class::RANGES.include?(sym)

      raise ArgumentError,
        "Unknown #{range}. Valid values: #{self.class::RANGES.join(', ')}"
    end
  end
end
