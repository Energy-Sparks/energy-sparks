module Elements
  class TagComponent < ApplicationComponent
    def initialize(tag, **kwargs)
      super
      @tag = tag
      @options = kwargs.except(:classes).merge(id: id, class: classes)
    end

    def call
      content_tag(@tag, @options) { content }
    end
  end
end
