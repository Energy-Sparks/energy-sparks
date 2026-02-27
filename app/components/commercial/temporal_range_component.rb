module Commercial
  class TemporalRangeComponent < ApplicationComponent
    RANGES = %i[all current historical future expiring].freeze

    def initialize(holder:, association_name:, range: :all, show_actions: true, range_param: nil, **kwargs)
      super(**kwargs)
      @holder = holder
      @association_name = association_name.to_sym
      @range = normalize_range(range)
      @show_actions = show_actions
      @range_param = range_param
    end

    def render?
      associations.any?
    end

    def associations
      if @range_param
        scoped_source.public_send(@range, @range_param).by_start_date
      else
        scoped_source.public_send(@range).by_start_date
      end
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
