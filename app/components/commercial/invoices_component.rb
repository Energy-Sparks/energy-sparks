# frozen_string_literal: true

module Commercial
  class InvoicesComponent < ApplicationComponent
    def initialize(invoices:,
                   show_contract: true, **)
      super(**)
      @invoices = invoices
      @show_contract = show_contract
    end
  end
end
