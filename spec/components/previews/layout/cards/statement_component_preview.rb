module Layout
  module Cards
    class StatementComponentPreview < ViewComponent::Preview
      def default
        render(Layout::Cards::StatementComponent.new(theme: :dark)) do |card|
          card.with_badge 'Badge text'
          card.with_statement { 'Tools component content' }
        end
      end
    end
  end
end
