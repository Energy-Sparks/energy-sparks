module Layout
  module Cards
    class FeatureComponent < LayoutComponent
      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: @main ? 2 : 4, theme: @theme }.merge(kwargs))
      end
      renders_many :tags, ->(*args, **kwargs) do
        Elements::BadgeComponent.new(*args, **{ classes: 'font-weight-normal text-uppercase' }.merge(kwargs))
      end
      renders_one :date, ->(date) { short_dates(date.to_s.to_date) }
      renders_one :author, ->(*args, **kwargs) do
        Elements::TagComponent.new(:a, *args, **merge_classes('', kwargs))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:p, **merge_classes('small pt-2 pb-2', kwargs))
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
