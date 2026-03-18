module Admin
  class PlaceholderComponent < ApplicationComponent
    BADGE_CLASSES = 'position-absolute top-0 start-0 badge text-bg-light fw-light ms-1 mt-1 z-3'.freeze
    DEFAULT = 'Contains placeholder data or images'.freeze

    def initialize(text = nil, label: 'Placeholder', **_kwargs)
      @text = text || DEFAULT
      @label = label
    end

    def call
      render Elements::TooltipComponent.new(@text, **(content ? {} : { classes: BADGE_CLASSES })) do
        content || @label
      end
    end
  end
end
