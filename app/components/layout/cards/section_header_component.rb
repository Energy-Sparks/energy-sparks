module Layout
  module Cards
    class SectionHeaderComponent < LayoutComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: 3 }.merge(kwargs))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:p, **{ classes: '' }.merge(kwargs))
      end

      def initialize(**_kwargs)
        super
        add_classes('text-center')
      end
    end
  end
end
