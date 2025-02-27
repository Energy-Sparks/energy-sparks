module Layout
  module Cards
    class StatementComponentPreview < ViewComponent::Preview
      def without_classes
        render(Layout::Cards::StatementComponent.new) do |card|
          card.with_header title: 'Header'
          card.with_description { 'Interesting text about the above figure' }
        end
      end
    end
  end
end
