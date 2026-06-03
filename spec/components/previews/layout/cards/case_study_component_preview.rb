# frozen_string_literal: true

module Layout
  module Cards
    class CaseStudyComponentPreview < ViewComponent::Preview
      # @param theme select { choices: [nil, dark, accent, light, pale, white] }
      # @param bs5 toggle
      def default(theme: nil, bs5: false) # rubocop:disable Lint/UnusedMethodArgument
        render(Layout::Cards::CaseStudyComponent.new(theme: theme.to_sym, classes: 'p-4')) do |card|
          card.with_image(src: 'laptop.jpg')
          card.with_header title: 'Powering a Greener Tomorrow'
          card.with_description { 'Every watt saved is a step towards a brighter future!' }
          card.with_tag('Energy')
          card.with_tag('Savings')
        end
      end
    end
  end
end
