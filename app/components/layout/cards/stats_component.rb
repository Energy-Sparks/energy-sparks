module Layout
  module Cards
    class StatsComponent < ApplicationComponent
      renders_one :icon, 'IconComponent'
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: 5, classes: 'text-white mt-2' }.merge(kwargs))
      end
      renders_one :figure, ->(figure, **kwargs) { Elements::HeaderComponent.new(**{ title: figure, level: 2, classes: 'figure text-blue-light' }.merge(kwargs)) }
      renders_one :subtext, ->(**kwargs) { Elements::TagComponent.new(:p, **{ classes: 'very-small text-blue-light' }.merge(kwargs)) }

      def initialize(**_kwargs)
        super
        add_classes('bg-blue-very-dark rounded-12 text-center p-4 h-100')
      end
    end
  end
end
