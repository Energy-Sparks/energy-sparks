module Layout
  module Cards
    class FeatureComponent < LayoutComponent
      attr_reader :size, :tag_position

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
        Elements::TagComponent.new(:div, classes: 'pt-2 pb-4', **kwargs)
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

      SIZES = { xl: 1, lg: 2, md: 3, sm: 4 }.freeze
      private_constant :SIZES
      TAG_POSITIONS = %i[top bottom].freeze
      private_constant :TAG_POSITIONS

      def initialize(size: :md, tag_position: :top, **_kwargs)
        super
        validate_inclusion size:, in: SIZES.keys
        validate_inclusion tag_position:, in: TAG_POSITIONS

        @size = size
        @tag_position = tag_position

        add_classes('d-flex flex-column')
      end

      def header_size
        SIZES[size]
      end

      def render_tags?(position)
        tag_position == position && tags.any?
      end

      def render_tags
        safe_join(tags, ' ')
      end
    end
  end
end
