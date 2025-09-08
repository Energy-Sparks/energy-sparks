module Elements
  class PriceComponentPreview < ViewComponent::Preview
    def default
      render(Elements::PriceComponent.new(label: 'starting from', price: '£2999 + VAT'))
    end
  end
end
