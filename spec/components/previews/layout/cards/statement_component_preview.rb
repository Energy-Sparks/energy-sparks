module Layout
  module Cards
    class StatementComponentPreview < ViewComponent::Preview
      def default
        render(Layout::Cards::StatementComponent.new) do |card|
          card.with_badge 'Badge text'
          card.with_statement title: 'Tools component content'
        end
      end
    end
  end
end
