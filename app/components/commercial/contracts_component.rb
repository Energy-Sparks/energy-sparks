module Commercial
  class ContractsComponent < ApplicationComponent
    RANGES = [:all, :current, :historical, :future].freeze

    def initialize(contract_holder:, range: :all, **kwargs)
      super
      validate_range(range)
      @range = range.to_sym
      @contract_holder = contract_holder
    end

    def render?
      contracts.any?
    end

    def contracts
      @contract_holder.contracts.public_send(@range)
    end

    private

    def validate_range(range)
      return if RANGES.include?(range.to_sym)
      raise ArgumentError, "Unknown #{range}. Valid values are: #{RANGES.join(', ')}"
    end
  end
end
