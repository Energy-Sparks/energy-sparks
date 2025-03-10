module Layout
  module Cards
    class TestimonialComponentPreview < ViewComponent::Preview
      def default
        render(Layout::Cards::TestimonialComponent.new) do |card|
          card.with_header title: 'Header'
          card.with_quote { 'Interesting quote about the above title' }
          card.with_source { '<strong>Name</strong><br>school'.html_safe }
          card.with_button 'Primary link', '/', style: :primary
          card.with_button 'Secondary link', '/', style: :secondary
        end
      end
    end
  end
end
