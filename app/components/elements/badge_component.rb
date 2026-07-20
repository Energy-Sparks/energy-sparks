module Elements
  class BadgeComponent < ApplicationComponent
    def initialize(text = nil, pill: false, colour: nil, themed: false, **_kwargs)
      super
      validate_colour_variant(colour: colour) if colour
      @text = text

      add_classes('d-inline-flex align-items-center badge')
      add_classes('rounded-pill') if pill
      add_classes("bg-#{colour}") if colour
      add_classes('text-dark') if !colour || [:light, :warning].include?(colour)
      add_classes('themed') if themed
    end

    def call
      tag.span(id: id, class: classes, **html_options) { "#{@text}#{content}".html_safe }
    end

    def render?
      @text || content
    end
  end
end
