module Elements
  class IframeComponentPreview < ViewComponent::Preview
    def default
      render(Elements::IframeComponent.new(type: :youtube, src: 'https://www.youtube.com/embed/PqoKZjwgmoY', classes: 'rounded-xl'))
    end
  end
end
