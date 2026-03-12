module Admin
  class PlaceholderComponent < ApplicationComponent
    BADGE_CLASSES = 'position-absolute top-0 start-0 badge text-bg-light fw-light ms-1 mt-1 z-3'.freeze

    def initialize(text = nil, badge: false, **_kwargs)
      @text = text || 'please replace me'
      @badge = badge
    end

    def call
      render Elements::TooltipComponent.new("Placeholder: #{@text}", **(content ? {} : { classes: BADGE_CLASSES })) do
        content || 'Placeholder'
      end
    end
  end
end
