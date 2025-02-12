module Elements
  class CardComponent < ApplicationComponent
    renders_one :icon, 'IconComponent'
    renders_one :header, ->(title) { Elements::HeaderComponent.new(title: title, level: 4, classes: 'text-white') }
    renders_one :figure, ->(figure) { Elements::HeaderComponent.new(title: figure, level: 3, classes: 'text-blue-light') }
    renders_one :subtext, -> { Elements::ParagraphComponent.new(classes: 'small text-blue-light') }

    def initialize(id: '', classes: '')
      super(id: id, classes: classes)
      add_classes('card-component')
    end
  end
end
