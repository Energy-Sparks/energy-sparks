module Cards
  class StatementComponent < ApplicationComponent
    renders_one :header, ->(title) { Elements::HeaderComponent.new(title: title, level: 3) }
    renders_one :description, -> { Elements::ParagraphComponent.new(classes: 'small') }

    def initialize(id: '', classes: '')
      super(id: id, classes: classes)
      add_classes('statement-card-component p-4 m-4 text-center')
    end
  end
end
