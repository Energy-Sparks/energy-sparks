# frozen_string_literal: true

module Commercial
  class PriceBreakdownComponent < ApplicationComponent
    def initialize(price:, id: 'price', **)
      super(id:, **)
      @price = price
    end
  end
end
