module Layout
  module Cards
    class PageHeaderComponentPreview < ViewComponent::Preview
      def default
        render(Layout::Cards::PageHeaderComponent.new(title: 'Page title', subtitle: 'Page subtitle'))
      end

      def themed
        render(Layout::Cards::PageHeaderComponent.new(theme: :accent, title: 'Page title', subtitle: 'Page subtitle'))
      end
    end
  end
end
