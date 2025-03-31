module Layout
  module Cards
    class TestimonialComponentPreview < ViewComponent::Preview
      def default
        render(Layout::Cards::TestimonialComponent.new(classes: 'p-4')) do |card|
          card.with_image(src: 'laptop.jpg')
          card.with_header title: 'Powering a Greener Tomorrow'
          card.with_quote { 'Every watt saved is a step towards a brighter future!' }
          card.with_name { 'Dr Watts' }
          card.with_role { 'Energy Champion' }
          card.with_organisation { 'Greenfields Academy' }
          card.with_case_study(CaseStudy.last)
        end
      end

      def with_theme_and_without_role
        render(Layout::Cards::TestimonialComponent.new(theme: :light, classes: 'p-4')) do |card|
          card.with_image(src: 'laptop.jpg')
          card.with_header title: 'Powering a Greener Tomorrow'
          card.with_quote { 'Every watt saved is a step towards a brighter future!' }
          card.with_name { 'Dr Watts' }
          card.with_organisation { 'Greenfields Academy' }
          card.with_case_study(CaseStudy.last)
        end
      end
    end
  end
end
