module Layout
  module Cards
    class FeatureComponent < ApplicationComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: 2 }.merge(kwargs))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:p, **{ classes: 'small' }.merge(kwargs))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **{ classes: 'pb-1' }.merge(kwargs))
      end

      def initialize(responsive: false, **_kwargs)
        super
        add_classes('responsive') if responsive
      end
    end
  end
end
