module Elements
  class ParagraphComponentPreview < ViewComponent::Preview
    def default
      render(Elements::ParagraphComponent.new) { 'Content' }
    end
  end
end
