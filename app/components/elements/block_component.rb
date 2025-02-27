module Elements
  class BlockComponent < ApplicationComponent
    def initialize(id: '', classes: '')
      super(id: id, classes: classes)
    end

    def render?
      content
    end

    def call
      @classes.present? || @id.present? ? tag.div(id: @id, class: @classes) { content } : content
    end
  end
end
