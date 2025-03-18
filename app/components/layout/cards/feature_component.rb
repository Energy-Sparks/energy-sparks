module Layout
  module Cards
    class FeatureComponent < ApplicationComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: @main ? 2 : 4, theme: @theme }.merge(kwargs))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:p, **{ classes: 'small' }.merge(kwargs))
      end
      renders_many :links, ->(*args, **kwargs) do
        Elements::TagComponent.new(:a, *args, **{ classes: 'pb-1' }.merge(kwargs))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **{ classes: 'pb-1' }.merge(kwargs))
      end

      def initialize(main: false, **_kwargs)
        super
        @main = main
        add_classes('main') if main
      end
    end
  end
end
