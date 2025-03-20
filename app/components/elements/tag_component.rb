module Elements
  class TagComponent < ApplicationComponent
    def initialize(*args, id: nil, classes: nil, **kwargs)
      super
      @id = id
      @classes = classes
      @args = args
      @kwargs = kwargs
    end

    def call
      content_tag(*@args, **@kwargs, id: id, class: classes) { content }
    end
  end
end
