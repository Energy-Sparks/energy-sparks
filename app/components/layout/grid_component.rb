module Layout
  class GridComponent < ApplicationComponent
    attr_reader :cols, :rows

    renders_many :cells, types: types(
      type(:block, Elements::BlockComponent),
      type(:icon, IconComponent),
      type(:image, Elements::ImageComponent),
      type(:tag, Elements::TagComponent),
      type(:prompt_list, PromptListComponent),
      type(:stats_card, Cards::StatsComponent),
      type(:feature_card, Cards::FeatureComponent),
      type(:testimonial_card, Cards::TestimonialComponent),
      type(:statement_card, Cards::StatementComponent),
      type(:card, CardComponent)
    )

    private

    def wrap(klass, *args, **kwargs, &block)
      kwargs[:classes] = class_names(kwargs[:classes], @component_classes)
      cell_classes = kwargs.delete(:cell_classes)

      tag.div(class: class_names(column_classes, cell_classes, @cell_classes)) do
        render(klass.new(*args, **kwargs), &block)
      end
    end

    def initialize(cols:, rows: 1, cell_classes: '', component_classes: '', **_kwargs)
      super

      @cols = cols
      @rows = rows

      @cell_classes = cell_classes
      @component_classes = component_classes
    end

    def render?
      cells.any?
    end

    def column_classes
      case cols
      when 2
        'col-12 col-md-6'
      when 3
        'col-12 col-md-4'
      when 4
        'col-12 col-xl-3 col-sm-6'
      when 6 # not currently in use
        'col-xl-2 col-lg-4 col-sm-6 col-xs-6'
      end
    end
  end
end
