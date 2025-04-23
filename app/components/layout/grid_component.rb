module Layout
  class GridComponent < LayoutComponent
    attr_reader :cols, :rows

    renders_many :cells, types: types(
      type(:block, Elements::BlockComponent),
      type(:icon, IconComponent),
      type(:image, Elements::ImageComponent),
      type(:paragraph, Elements::TagComponent, :p),
      type(:prompt_list, PromptListComponent),
      type(:stats_card, Cards::StatsComponent),
      type(:feature_card, Cards::FeatureComponent),
      type(:testimonial_card, Cards::TestimonialComponent),
      type(:statement_card, Cards::StatementComponent),
      type(:card, CardComponent),
      cell: { renders: ->(**kwargs, &block) { cell(**kwargs) { capture(&block) } }, as: :cell }
    )

    private

    def wrap(klass, *args, **kwargs, &block)
      cell(**kwargs) do
        render(klass.new(*args, **kwargs), &block)
      end
    end

    def cell(**kwargs, &block)
      tag.div(class: class_names(column_classes, kwargs.delete(:cell_classes), @cell_classes), &block)
    end

    def initialize(cols:, rows: 1, cell_classes: '', **_kwargs)
      super

      @cols = cols
      @rows = rows

      @cell_classes = cell_classes
    end

    def render?
      cells.any?
    end

    def column_classes
      case cols
      when 2
        'col-12 col-md-6'
      when 3
        'col-12 col-md-4 col-sm-12'
      when 4
        'col-12 col-xl-3 col-sm-6'
      when 6 # not currently in use
        'col-xl-2 col-lg-4 col-sm-6 col-xs-6'
      end
    end
  end
end
