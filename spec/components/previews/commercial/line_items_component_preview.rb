# frozen_string_literal: true

module Commercial
  class LineItemsComponentPreview < ViewComponent::Preview
    def example
      render Commercial::LineItemsComponent.new(invoice: ::Commercial::Invoice.all.sample)
    end
  end
end
