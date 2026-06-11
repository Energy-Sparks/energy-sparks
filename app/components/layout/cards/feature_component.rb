module Layout
  module Cards
    class FeatureComponent < LayoutComponent
      attr_reader :size, :position

      renders_one :header, lambda { |**kwargs|
        Elements::HeaderComponent.new(level: header_size, **kwargs)
      }
      renders_one :price, lambda { |**kwargs|
        Elements::PriceComponent.new(**merge_classes('', kwargs))
      }
      renders_many :tags, lambda { |*args, **kwargs|
        Elements::BadgeComponent.new(*args, classes: 'fw-normal text-uppercase', **kwargs)
      }
      renders_one :date, ->(date) { short_dates(date.to_s.to_date) }
      renders_one :datetime, ->(datetime) { nice_date_times(datetime.to_s.to_datetime) }
      renders_one :author, lambda { |*args, **kwargs|
        Elements::TagComponent.new(:a, *args, **merge_classes('', kwargs))
      }
      renders_one :description, lambda { |**kwargs|
        Elements::TagComponent.new(:div, **merge_classes('pt-2 pb-4', kwargs))
      }
      renders_many :buttons, lambda { |*args, **kwargs|
        Elements::ButtonComponent.new(*args,  classes: 'mb-1 me-2', **kwargs)
      }
      renders_many :links, lambda { |*args, **kwargs|
        Elements::TagComponent.new(:a, *args, **merge_classes('mb-1 mt-auto', kwargs))
      }
      renders_many :blocks, lambda { |**kwargs|
        Elements::TagComponent.new(:div, **merge_classes('mt-auto', kwargs))
      }

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
        'Size must be: ' + sizes.keys.to_sentence(two_words_connector: ' or ')
      end
    end
  end
end
