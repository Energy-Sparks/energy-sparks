# frozen_string_literal: true

module Elements
  class DropdownButtonComponent < ApplicationComponent
    attr_reader :name, :items

    def initialize(name, items, **kwargs)
      super
      @name = name
      @items = items
      @style = kwargs.fetch(:style, :secondary)
      @size = kwargs.fetch(:size, nil)
      @outline = kwargs.fetch(:outline, false)
      @data = kwargs.fetch(:data, {})
      add_classes('dropdown')
    end

    def call
      tag.div(class: classes) do
        toggle + menu
      end
    end

    private

    def toggle
      render Elements::ButtonComponent.new(
        @name, '#',
        id: dropdown_id,
        classes: 'dropdown-toggle',
        style: @style,
        size: @size,
        outline: @outline,
        data: { toggle: 'dropdown', bs_toggle: 'dropdown' }.merge(@data)
      )
    end

    def menu
      tag.div(class: 'dropdown-menu', aria: { labelledby: dropdown_id }) do
        safe_join(items.map { |item_name, url| link_to(item_name, url, class: 'dropdown-item') })
      end
    end

    def dropdown_id
      @dropdown_id ||= @id || "dropdown-#{SecureRandom.hex(4)}"
    end
  end
end
