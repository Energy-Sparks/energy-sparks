module Cards
  class FeatureComponentPreview < ViewComponent::Preview
    def without_classes
      render(Cards::FeatureComponent.new) do |card|
        card.with_header title: 'Header'
        card.with_description { 'Interesting text' }
        card.with_button 'Primary link', '/', style: :primary
        card.with_button 'Secondary link', '/', style: :secondary
      end
    end
  end
end
