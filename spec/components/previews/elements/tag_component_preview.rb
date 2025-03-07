module Elements
  class TagComponentPreview < ViewComponent::Preview
    def paragraph
      render(Elements::TagComponent.new(:p)) { 'Content' }
    end

    def quote
      render(Elements::TagComponent.new(:q)) { 'Content' }
    end
  end
end
