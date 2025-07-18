module Layout
  module Cards
    class PageHeaderComponent < LayoutComponent
      def initialize(title:, subtitle: nil, theme: :pale, **_kwargs)
        super
        @title = title
        @subtitle = subtitle
      end
    end
  end
end
