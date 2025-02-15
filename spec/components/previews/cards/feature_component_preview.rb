module Cards
  class FeatureComponentPreview < ViewComponent::Preview
    def without_classes
      render(Cards::FeatureComponent.new) do |card|
        card.with_header 'Header'
        card.with_description { 'Interesting text' }
        card.with_buttons { 'Buttons go here. Probably need actual buttons (coming soon)' }
      end
    end
  end
end
