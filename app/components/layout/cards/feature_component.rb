module Layout
  module Cards
    class FeatureComponent < ApplicationComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**kwargs.merge({ level: 2 }))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:p, **kwargs.merge({ classes: 'small' }))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **kwargs.merge({ classes: 'pb-1' }))
      end
    end
  end
end
