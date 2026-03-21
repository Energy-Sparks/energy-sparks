module Admin
  class PlaceholderComponent < ApplicationComponent
    BADGE_CLASSES = 'position-absolute top-0 badge text-bg-light fw-light mt-1 z-3'.freeze
    DEFAULT = 'Contains placeholder data or images'.freeze

    def initialize(text = nil, label: 'Placeholder', placement: :left, **_kwargs)
      @text = text || DEFAULT
      @label = label
      @placement = placement
    end

    def badge_classes
      @placement == :right ? "#{BADGE_CLASSES} end-0 me-1" : "#{BADGE_CLASSES} start-0 ms-1"
    end

    def call
      render Elements::TooltipComponent.new(@text, **(content ? {} : { classes: badge_classes })) do
        content || @label
      end
    end
  end
end
