module Elements
  class BadgeComponent < ApplicationComponent
    def initialize(text = nil, pill: false, style: :primary, **_kwargs)
      super
      raise ArgumentError, 'Unknown badge style' if style && !self.class.styles.include?(style)
      @text = text
      @style = style

      add_classes('d-inline-flex align-items-center badge')
      add_classes('rounded-pill') if pill
      if style
        add_classes("bg-#{style}")
        add_classes('text-dark') if [:light, :warning].include?(style)
      end
    end

    def call
      tag.span(id: id, class: classes) { "#{@text}#{content}".html_safe }
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
