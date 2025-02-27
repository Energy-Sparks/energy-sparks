module Elements
  class ImageComponentPreview < ViewComponent::Preview
    def default
      render(Elements::ImageComponent.new(src: 'laptop.jpg'))
    end
  end
end
