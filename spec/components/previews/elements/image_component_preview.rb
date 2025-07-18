module Elements
  class ImageComponentPreview < ViewComponent::Preview
    def default
      render(Elements::ImageComponent.new(src: 'laptop.jpg'))
    end

    def with_frame
      render(Elements::ImageComponent.new(src: 'funders.png', frame: true))
    end
  end
end
