# frozen_string_literal: true

module Commercial
  class PendingInvoicingComponent < ApplicationComponent
    def initialize(contracts:, **)
      super(**)
      @contracts = contracts
    end
  end
end
