module Layout
  module Cards
    class TestimonialComponentPreview < ViewComponent::Preview
      def default
        render(Layout::Cards::TestimonialComponent.new) do |card|
          card.with_header title: 'Powering a Greener Tomorrow'
          card.with_quote { 'Every watt saved is a step towards a brighter future!' }
          card.with_name { 'Dr Watts' }
          card.with_role { 'Energy Champion' }
          card.with_location { 'Greenfields Academy' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end

      def with_theme_and_without_role
        render(Layout::Cards::TestimonialComponent.new(theme: :light)) do |card|
          card.with_header title: 'Powering a Greener Tomorrow'
          card.with_quote { 'Every watt saved is a step towards a brighter future!' }
          card.with_name { 'Dr Watts' }
          card.with_location { 'Greenfields Academy' }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end
    end
  end
end
