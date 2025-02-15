module Cards
  class FeatureComponent < ApplicationComponent
    # Header text-white needs to be elsewhere
    renders_one :header, ->(title) { Elements::HeaderComponent.new(title: title, level: 2, classes: 'text-white') }
    renders_one :description, -> { Elements::ParagraphComponent.new(classes: 'small') }
    renders_one :buttons, -> { Elements::ParagraphComponent.new }
    # need to make a button component for this. Out of scope for this PR.
    # renders_one :primary_button, -> { Elements::ButtonComponent.new() }
    # renders_one :secondary_button, -> { Elements::ButtonComponent.new() }

    def initialize(id: '', classes: '')
      super(id: id, classes: classes)
      add_classes('feature-card-component py-4')
    end
  end
end
