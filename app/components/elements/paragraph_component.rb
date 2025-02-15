module Elements
  class ParagraphComponent < ApplicationComponent
    def initialize(id: '', classes: '')
      super(id: id, classes: classes)
    end

    def call
      tag.p(id: @id, class: @classes) { content }
    end
  end
end
