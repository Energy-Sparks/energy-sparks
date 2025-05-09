# frozen_string_literal: true

module Costs
  class AgreedSupplyCapacitySummary
    attr_reader :kw, :agreed_limit_kw, :annual_cost_£, :annual_saving_£

    def initialize(kw:, agreed_limit_kw:, annual_cost_£: nil, annual_saving_£: nil)
      @kw = kw
      @agreed_limit_kw = agreed_limit_kw
      @annual_cost_£ = annual_cost_£
      @annual_saving_£ = annual_saving_£
    end

    def percentage
      @kw / @agreed_limit_kw
    end
  end
end
