module Layout
  module Cards
    class SectionHeaderComponentPreview < ViewComponent::Preview
      def without_classes
        render(Layout::Cards::SectionHeaderComponent.new) do |card|
          card.with_header title: 'Header'
          card.with_description { 'Interesting text about the above header' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end
    end
  end
end
