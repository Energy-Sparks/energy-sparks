module Elements
  class ImageComponent < ApplicationComponent
    def initialize(src:, collapse: false, stretch: false, width: nil, id: '', classes: '')
      super(id: id, classes: classes)
      @src = src
      @collapse = collapse
      @stretch = stretch
      @width = width
      validate
      setup_classes
    end

    def setup_classes
      add_classes('image-component')
      if @stretch
        add_classes('stretch')
        add_classes('left') if @stretch == :left
        add_classes('right') if @stretch == :right
      end
      add_classes('d-none d-md-block') if @collapse
    end

    def call
      tag.img(src: image_path(@src), id: @id, class: classes, style: @width && "width: #{@width};")
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
