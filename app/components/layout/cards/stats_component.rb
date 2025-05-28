module Layout
  module Cards
    class StatsComponent < LayoutComponent
      renders_one :icon, 'IconComponent'
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: 5, classes: 'mt-2' }.merge(kwargs))
      end
      renders_one :figure, ->(figure, **kwargs) { Elements::HeaderComponent.new(**{ title: figure, level: 2, classes: 'figure text-complement' }.merge(kwargs)) }
      renders_one :subtext, ->(**kwargs) { Elements::TagComponent.new(:p, **{ classes: 'small text-complement' }.merge(kwargs)) }

      def initialize(**_kwargs)
        super
        add_classes('rounded-xl text-center p-4 h-100')
      end
    end
  end
end
