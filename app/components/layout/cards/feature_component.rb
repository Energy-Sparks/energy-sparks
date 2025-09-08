module Layout
  module Cards
    class FeatureComponent < LayoutComponent
      attr_reader :size, :position

      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: header_size }.merge(kwargs))
      end
      renders_one :price, ->(**kwargs) do
        Elements::PriceComponent.new(**merge_classes('', kwargs))
      end
      renders_many :tags, ->(*args, **kwargs) do
        Elements::BadgeComponent.new(*args, **{ classes: 'font-weight-normal text-uppercase' }.merge(kwargs))
      end
      renders_one :date, ->(date) { short_dates(date.to_s.to_date) }
      renders_one :datetime, ->(datetime) { nice_date_times(datetime.to_s.to_datetime) }
      renders_one :author, ->(*args, **kwargs) do
        Elements::TagComponent.new(:a, *args, **merge_classes('', kwargs))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:div, **merge_classes('pt-2 pb-4', kwargs))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **merge_classes('mb-1 mr-2', kwargs))
      end
      renders_many :links, ->(*args, **kwargs) do
        Elements::TagComponent.new(:a, *args, **merge_classes('mb-1 mt-auto', kwargs))
      end

      def initialize(size: :md, **_kwargs)
        super
        @size = size
        raise ArgumentError.new(self.class.size_error) unless self.class.sizes.key?(@size.to_sym)
        add_classes('d-flex flex-column')
      end

      def self.sizes
        { xl: 1, lg: 2, md: 3, sm: 4 }
      end

      def header_size
        self.class.sizes[size]
      end

      def self.size_error
        'Size must be: ' + self.sizes.keys.to_sentence(two_words_connector: ' or ')
      end
    end
  end
end
