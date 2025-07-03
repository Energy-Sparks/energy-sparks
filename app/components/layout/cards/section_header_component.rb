module Layout
  module Cards
    class SectionHeaderComponent < LayoutComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: 2, classes: 'mb-0' }.merge(kwargs))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:p, **{ classes: 'mb-0' }.merge(kwargs))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **merge_classes('me-2', kwargs))
      end

      def initialize(**_kwargs)
        super
        add_classes('row my-4')
      end
    end
  end
end
