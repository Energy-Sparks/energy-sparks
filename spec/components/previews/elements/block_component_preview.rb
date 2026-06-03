module Elements
  class BlockComponentPreview < ViewComponent::Preview
    def without_classes
      render(Elements::BlockComponent.new) do
        'Content'
      end
    end

    def with_classes
      render(Elements::BlockComponent.new(classes: 'my-classes')) do
        'Content'
      end
    end

    def with_id
      render(Elements::BlockComponent.new(id: 'my-id')) do
        'Content'
      end
    end
  end
end
