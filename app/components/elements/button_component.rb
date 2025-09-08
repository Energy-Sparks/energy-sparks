module Elements
  class ButtonComponent < ApplicationComponent
    def initialize(name, url, style: nil, size: nil, outline: false, outline_style: :white, data: {}, **_kwargs)
      super
      raise ArgumentError, 'Unknown button style' if style && !self.class.styles.include?(style)
      raise ArgumentError, 'Unknown button size' if size && !self.class.sizes.include?(size)
      raise ArgumentError, 'Unknown button outline style' if outline_style && !self.class.outline_styles.include?(outline_style)

      @name = name
      @url = url
      @data = data
      btn = outline ? 'btn-outline' : 'btn'
      btn += "-#{style}" if style
      add_classes('transparent') if outline_style == :transparent
      add_classes("btn #{btn}")
      add_classes("btn-#{size}") if size
    end

    def call
      tag.a(id: @id, class: @classes, href: @url, data: @data) { "#{@name}#{content}" }
    end

    class << self
      def styles
        [:primary, :secondary, :success, :info, :warning, :danger, :light, :dark, :white]
      end

      def sizes
        [:xs, :sm, :lg]
      end

      def outline_styles
        [:transparent, :white]
      end
    end
  end
end
