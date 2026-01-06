module Elements
  class HeaderComponentPreview < ViewComponent::Preview
    def h1
      render(Elements::HeaderComponent.new(title: 'Header level 1', level: 1))
    end

    def h2
      render(Elements::HeaderComponent.new(title: 'Header level 2', level: 2))
    end

    def h3
      render(Elements::HeaderComponent.new(title: 'Header level 3', level: 3))
    end

    def h4
      render(Elements::HeaderComponent.new(title: 'Header level 4', level: 4))
    end

    def h5
      render(Elements::HeaderComponent.new(title: 'Header level 5', level: 5))
    end

    def h6
      render(Elements::HeaderComponent.new(title: 'Header level 6', level: 6))
    end

    def header_with_block
      render(Elements::HeaderComponent.new(title: 'Header with block')) { 'Block text' }
    end
  end
end
