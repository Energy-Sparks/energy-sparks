module Layout
  module Cards
    class FeatureComponent < ApplicationComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**({ level: 2 }.merge(kwargs)))
      end
      renders_one :description, ->(**kwargs) do
        Elements::ParagraphComponent.new(**({ classes: 'small' }.merge(kwargs)))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **kwargs)
      end

      def initialize(id: '', classes: '')
        super(id: id, classes: classes)
        add_classes('feature-card-component py-4')
      end
    end
  end
end
