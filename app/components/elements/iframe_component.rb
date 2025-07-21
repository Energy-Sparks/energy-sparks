module Elements
  class IframeComponent < ApplicationComponent
    def initialize(type: :youtube, src:, iframe_classes: nil, min_height: '320px', **_kwargs)
      super
      @src = src
      @type = type
      @iframe_classes = class_names(iframe_classes) if iframe_classes
      @min_height = min_height
      add_classes('overflow-hidden h-100')
    end

    def call
      tag.div(id: @id, class: @classes) do
        if @type == :youtube
          tag.iframe(src: @src, class: @iframe_classes || 'h-100 w-100',
            frameborder: 0, style: "min-height: #{@min_height};",
            scrolling: 'no', allowfullscreen: true)
        else
          tag.iframe(src: @src, class: @iframe_classes)
        end
      end
    end
  end
end
