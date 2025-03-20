module Layout
  module Cards
    class FeatureComponent < LayoutComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: @main ? 2 : 4, theme: @theme }.merge(kwargs))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:p, **merge_classes('small', kwargs))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **merge_classes('mb-1 mr-2', kwargs))
      end
      renders_many :links, ->(*args, **kwargs) do
        Elements::TagComponent.new(:a, *args, **merge_classes('small mb-1 mt-auto', kwargs))
      end

      def initialize(main: false, **_kwargs)
        super
        @main = main
        add_classes('d-flex flex-column')
        add_classes('main') if main
      end
    end
  end
end
