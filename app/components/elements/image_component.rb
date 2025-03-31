module Elements
  class ImageComponent < ApplicationComponent
    def initialize(src:, fit: true, collapse: false, stretch: false, width: nil, height: nil, **_kwargs)
      super
      @src = src
      @fit = fit
      @collapse = collapse
      @stretch = stretch
      @width = width
      @height = height
      validate
      setup_classes
    end

    def setup_classes
      if @stretch
        add_classes('stretch')
        add_classes('left') if @stretch == :left
        add_classes('right') if @stretch == :right
      elsif @fit
        add_classes('fit')
      end
      add_classes('d-none d-md-block') if @collapse
    end

    def style
      style = ''
      style += "width: #{@width};" if @width
      style += " height: #{@height};" if @height
      style
    end

    def call
      image_tag(@src, id: @id, class: classes, style: style)
    end

    def validate
      raise ArgumentError.new(self.class.stretch_error) if @stretch && !self.class.stretch.include?(@stretch.to_sym)
    end

    def self.stretch
      [:left, :right]
    end

    def self.stretch_error
      'Stretch must be: ' + self.stretch.to_sentence(two_words_connector: ' or ')
    end
  end
end
