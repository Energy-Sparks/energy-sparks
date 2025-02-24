module Elements
  class ButtonComponent < ApplicationComponent
    def initialize(name, url, style: nil, size: nil, outline: false, id: nil, classes: nil)
      super(id: id, classes: classes)
      raise ArgumentError, 'Unknown button style' if style && !self.class.styles.include?(style)
      raise ArgumentError, 'Unknown button size' if size && !self.class.sizes.include?(size)
      @name = name
      @url = url

      btn = outline ? 'btn-outline' : 'btn'
      btn += "-#{style}" if style
      add_classes("btn #{btn}")
      add_classes("btn-#{size}") if size
    end

    def call
      tag.a(id: @id, class: @classes, href: @url) { "#{@name}#{content}" }
    end

    class << self
      def styles
        [:primary, :secondary, :success, :info, :warning, :danger, :light, :dark, :white]
      end

      def sizes
        [:xs, :sm, :lg]
      end
    end
  end
end
