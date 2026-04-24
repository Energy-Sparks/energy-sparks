# frozen_string_literal: true

module Commercial
  class PriceBreakdownComponent < ApplicationComponent
    def initialize(price:, **)
      super(**)
      @price = price
    end
  end
end
