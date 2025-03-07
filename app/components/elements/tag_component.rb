module Elements
  class TagComponent < ApplicationComponent
    def initialize(tag, **kwargs)
      super
      @tag = tag
    end

    def call
      content_tag(@tag, id: id, class: classes) { content }
    end

    def render?
      content
    end
  end
end
