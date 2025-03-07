module Elements
  class ButtonComponentPreview < ViewComponent::Preview
    def plain
      render(Elements::ButtonComponent.new('text', '/'))
    end

    def with_style
      render(Elements::ButtonComponent.new('text', '/', style: :success))
    end

    def with_outline
      render(Elements::ButtonComponent.new('text', '/', style: :info, outline: true))
    end

    def with_outline_transparent
      render(Elements::ButtonComponent.new('text', '/', style: :info, outline: true, outline_style: :transparent))
    end

    def with_size_xs
      render(Elements::ButtonComponent.new('text', '/', size: :xs))
    end

    def with_size_sm
      render(Elements::ButtonComponent.new('text', '/', size: :sm))
    end

    def with_size_lg
      render(Elements::ButtonComponent.new('text', '/', size: :lg))
    end
  end
end
