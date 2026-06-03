module Elements
  class BadgeComponent < ApplicationComponent
    def initialize(text = nil, pill: false, colour: nil, **_kwargs)
      super
      self.class.raise_unknown_variant_error(colour: colour) if colour
      @text = text

      add_classes('d-inline-flex align-items-center badge')
      add_classes('rounded-pill') if pill
      add_classes("bg-#{colour}") if colour
      add_classes('text-dark') if !colour || [:light, :warning].include?(colour)
    end

    def call
      tag.span(id: id, class: classes) { "#{@text}#{content}".html_safe }
    end

    def render?
      @text || content
    end
  end
end
