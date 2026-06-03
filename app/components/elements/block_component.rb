module Elements
  class BlockComponent < ApplicationComponent
    def render?
      content
    end

    def call
      tag.div(id: @id, class: @classes) { content }
    end
  end
end
