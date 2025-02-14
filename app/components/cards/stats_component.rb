module Cards
  class StatsComponent < ApplicationComponent
    renders_one :icon, 'IconComponent'
    renders_one :header, ->(title) { Elements::HeaderComponent.new(title: title, level: 5, classes: 'header text-white mt-2') }
    renders_one :figure, ->(figure) { Elements::HeaderComponent.new(title: figure, level: 2, classes: 'figure text-blue-light') }
    renders_one :subtext, -> { Elements::ParagraphComponent.new(classes: 'very-small text-blue-light') }

    def initialize(id: '', classes: '')
      super(id: id, classes: classes)
      add_classes('stats-card-component')
    end
  end
end
