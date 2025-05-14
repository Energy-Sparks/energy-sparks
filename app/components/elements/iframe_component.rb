module Elements
  class IframeComponent < ApplicationComponent
    def initialize(src:, **_kwargs)
      super
      @src = src
      add_classes('overflow-hidden h-100')
    end

    def call
      tag.div(id: @id, class: @classes) do
        tag.iframe(src: @src, class: 'h-100 w-100', style: 'object-fit: cover; min-height: 40vh;')
      end
    end
  end
end
