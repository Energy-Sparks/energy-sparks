module Elements
  class ImageComponent < ApplicationComponent
    def initialize(src:, fit: true, collapse: false, width: nil, height: nil, rounded: :all, frame: false, **_kwargs)
      super
      @src = src
      @fit = fit
      @collapse = collapse
      @width = width
      @height = height
      @rounded = rounded
      @frame = frame
      validate
      setup_classes
    end

    def setup_classes
      add_classes('fit') if @fit && !@frame
      add_classes('w-100') if @frame
      add_classes(self.class.rounded[@rounded]) if @rounded
      add_classes('d-none d-lg-block') if @collapse
    end

    def style
      style = ''
      style += "width: #{@width};" if @width
      style += " height: #{@height};" if @height
      style
    end

    def call
      img = image_tag(@src, id: @id, class: classes, style: style)
      if @frame
        classes = 'bg-white h-100 w-100 d-flex align-items-center justify-content-center'
        classes = class_names(classes, self.class.rounded[@rounded]) if @rounded
        tag.div(class: classes) { img }
      else
        img
      end
    end

    def validate
      raise ArgumentError.new(self.class.rounded_error) if @rounded && !self.class.rounded.key?(@rounded.to_sym)
    end

    def self.rounded
      {
        top: 'rounded-top-xl',
        bottom: 'rounded-bottom-xl',
        all: 'rounded-xl'
      }
    end

    def self.rounded_error
      'Rounded must be: ' + self.rounded.keys.to_sentence(two_words_connector: ' or ')
    end
  end
end
