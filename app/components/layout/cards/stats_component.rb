module Layout
  module Cards
    class StatsComponent < ApplicationComponent
      renders_one :icon, 'IconComponent'
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**({ level: 5, classes: 'text-white mt-2' }.merge(kwargs)))
      end
      renders_one :figure, ->(figure) { Elements::HeaderComponent.new(title: figure, level: 2, classes: 'figure text-blue-light') }
      renders_one :subtext, -> { Elements::ParagraphComponent.new(classes: 'very-small text-blue-light') }

      def initialize(id: '', classes: '')
        super(id: id, classes: classes)
        add_classes('stats-card-component bg-blue-very-dark rounded-12 text-center p-4 h-100')
      end
    end
  end
end
