module Layout
  module Cards
    class SectionHeaderComponent < ApplicationComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**kwargs.merge({ level: 3 }))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:p, **kwargs.merge({ classes: '' }))
      end

      def initialize(**_kwargs)
        super
        add_classes('p-4 m-4 text-center')
      end
    end
  end
end
