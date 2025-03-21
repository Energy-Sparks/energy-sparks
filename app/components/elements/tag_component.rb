module Elements
  class TagComponent < ApplicationComponent
    def initialize(tag, content_or_options = nil, options = nil, escape = true, **kwargs)
      super

      @tag = tag
      if content_or_options.is_a?(Hash)
        @content = nil
        @options = content_or_options
      else
        @content = content_or_options
        @options = options || {}
      end
      @options.merge!(kwargs).merge!(id: id, class: classes)
    end

    def call
      content_tag(@tag, @content || content, @options, @escape)
    end
  end
end
