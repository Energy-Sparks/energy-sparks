module Elements
  class TooltipComponent < ApplicationComponent
    def initialize(text = nil, **_kwargs)
      super
      @text = text
    end

    def render?
      !!content
    end

    def call
      return content unless @text
      content_tag(:span, content, id: id, class: classes, title: @text,
        data: { bs_toggle: 'tooltip', toggle: 'tooltip' })
    end
  end
end
