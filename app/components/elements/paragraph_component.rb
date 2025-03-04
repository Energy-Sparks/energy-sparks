module Elements
  class ParagraphComponent < ApplicationComponent
    def call
      tag.p(id: @id, class: @classes) { content }
    end

    def render?
      content
    end
  end
end
