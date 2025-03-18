module Elements
  class TagComponent < ApplicationComponent
    def initialize(*args, **kwargs)
      super
      @args = args
      @kwargs = kwargs
    end

    def call
      content_tag(*@args, **@kwargs, id: id, class: classes) { content }
    end
  end
end
