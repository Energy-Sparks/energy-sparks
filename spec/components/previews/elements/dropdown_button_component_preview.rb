# frozen_string_literal: true

module Elements
  class DropdownButtonComponentPreview < ViewComponent::Preview
    ITEMS = [['Edit', '#edit'], ['Delete', '#delete']].freeze

    # @param bs5 toggle
    def default(bs5: true) # rubocop:disable Lint/UnusedMethodArgument
      render(Elements::DropdownButtonComponent.new('Actions', ITEMS))
    end

    # @param bs5 toggle
    def outline_primary(bs5: true) # rubocop:disable Lint/UnusedMethodArgument
      render(Elements::DropdownButtonComponent.new('Actions', ITEMS, style: :primary, outline: true))
    end

    # @param bs5 toggle
    def with_size(bs5: true) # rubocop:disable Lint/UnusedMethodArgument
      render(Elements::DropdownButtonComponent.new('Actions', ITEMS, size: :sm))
    end

    # @param bs5 toggle
    def with_custom_id(bs5: true) # rubocop:disable Lint/UnusedMethodArgument
      render(Elements::DropdownButtonComponent.new('Actions', ITEMS, id: 'custom-dropdown'))
    end
  end
end
