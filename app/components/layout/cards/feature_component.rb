module Layout
  module Cards
    class FeatureComponent < LayoutComponent
      attr_reader :size, :position

      renders_one :header, ->(**kwargs) do
        Elements::HeaderComponent.new(**{ level: header_size, theme: @theme }.merge(kwargs))
      end
      renders_one :price, ->(**kwargs) do
        Elements::PriceComponent.new(**merge_classes('', kwargs))
      end
      renders_many :tags, ->(*args, **kwargs) do
        Elements::BadgeComponent.new(*args, **{ classes: 'font-weight-normal text-uppercase' }.merge(kwargs))
      end
      renders_one :date, ->(date) { short_dates(date.to_s.to_date) }
      renders_one :author, ->(*args, **kwargs) do
        Elements::TagComponent.new(:a, *args, **merge_classes(text_class.to_s, kwargs))
      end
      renders_one :description, ->(**kwargs) do
        Elements::TagComponent.new(:p, **merge_classes("pt-2 pb-2#{text_class}", kwargs))
      end
      renders_many :buttons, ->(*args, **kwargs) do
        Elements::ButtonComponent.new(*args, **merge_classes('mb-1 mr-2', kwargs))
      end
      renders_many :links, ->(*args, **kwargs) do
        Elements::TagComponent.new(:a, *args, **merge_classes("mb-1 mt-auto #{text_class}", kwargs))
      end

      def initialize(size: :md, position: nil, **_kwargs)
        super
        @size = size
        @position = position
        raise ArgumentError.new(self.size_error) unless self.class.sizes.key?(@size.to_sym)
        raise ArgumentError.new(self.position_error) if @position && !self.class.positions.include?(@position.to_sym)
        add_classes('d-flex flex-column')
        add_classes("position-#{position}") if position
      end

      def self.sizes
        { lg: 1, md: 2, sm: 3, xs: 4 }
      end

      def self.positions
        [:left, :right]
      end

      def header_size
        self.class.sizes[size]
      end

      def text_class
        size == :xs ? ' small' : ''
      end

      def self.size_error
        'Size must be: ' + self.sizes.keys.to_sentence(two_words_connector: ' or ')
      end

      def self.position_error
        'Position must be: ' + self.positions.to_sentence(two_words_connector: ' or ')
      end
    end
  end
end
