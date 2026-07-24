# frozen_string_literal: true

module Commercial
  class LineItemsComponent < ApplicationComponent
    def initialize(invoice:, **)
      super(**)
      @invoice = invoice
    end
  end
end
