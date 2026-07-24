# frozen_string_literal: true

module Layout
  module Cards
    class ContentActionPreview < ViewComponent::Preview
      # @param bs5 toggle
      def default(bs5: false) # rubocop:disable Lint/UnusedMethodArgument
        render(Layout::Cards::ContentAction.new(theme: :light)) do |card|
          card.with_body { 'Body content' }
          card.with_action { tag.button 'Action', class: 'btn btn-primary' }
        end
      end
    end
  end
end
