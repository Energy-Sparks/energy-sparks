# frozen_string_literal: true

module Commercial
  class PriceBreakdownComponentPreview < ViewComponent::Preview
    def example
      render Commercial::PriceBreakdownComponent.new(
        price: Price.new(base_price: 100.0, metering_fee: 50.0, private_account_fee: 95.0)
      )
    end
  end
end
