module Layout
  module Cards
    class FeatureComponentPreview < ViewComponent::Preview
      def without_classes
        render(Layout::Cards::FeatureComponent.new) do |card|
          card.with_header title: 'Header'
          card.with_description { 'Interesting text' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end

      def responsive
        render(Layout::Cards::FeatureComponent.new(responsive: true)) do |card|
          card.with_header title: 'Text should scale up on XL'
          card.with_description { 'Watch me scale!' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end
    end
  end
end
