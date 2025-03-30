module Elements
  class BadgeComponent < ApplicationComponent
    def initialize(text = nil, pill: false, style: :primary, **_kwargs)
      super
      raise ArgumentError, 'Unknown badge style' if style && !self.class.styles.include?(style)
      @text = text
      @style = style

      add_classes('badge')
      add_classes('badge-pill') if pill
      add_classes("badge-#{style}") if style
    end

    def call
      tag.span(id: id, class: classes) { "#{@text}#{content}" }
    end

    def render?
      @text || content
    end

    class << self
      def styles
        [:primary, :secondary, :success, :info, :warning, :danger, :light, :dark]
      end
    end
  end
end
