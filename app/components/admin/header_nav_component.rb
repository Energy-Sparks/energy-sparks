# frozen_string_literal: true

module Admin
  class HeaderNavComponent < ApplicationComponent
    renders_one :header, lambda { |level: 1, **kwargs|
      Elements::HeaderComponent.new(level:, **kwargs)
    }
    renders_many :actions, types: {
      button: {
        renders: lambda { |*args, size: :sm, **kwargs|
          Elements::ButtonComponent.new(*args, size:, **kwargs)
        },
        as: :button
      },
      dropdown: {
        renders: lambda { |title:, items:, outline: true, style: :primary, **kwargs|
          Elements::DropdownButtonComponent.new(
            title, items, outline:, style:, **merge_classes('d-inline-block', kwargs)
          )
        },
        as: :dropdown
      },
      action: {
        renders: ->(component) { component },
        as: :action
      }
    }
  end
end
