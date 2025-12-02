module Layout
  class GridComponent < LayoutComponent
    attr_reader :cols, :feature

    renders_many :cells, types: types(
      type(:block, Elements::BlockComponent),
      type(:icon, Elements::IconComponent),
      type(:image, Elements::ImageComponent),
      type(:iframe, Elements::IframeComponent),
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
      cell(klass, **kwargs) do
        render(klass.new(*args, **kwargs), &block)
      end
    end

    def cell(klass = nil, column_classes: nil, **kwargs, &block)
      tag.div(class: class_names(column_classes || default_column_classes, kwargs.delete(:cell_classes), @cell_classes, responsive_classes(klass)), &block)
    end

    def responsive_classes(klass)
      if cols == 2 && klass == Elements::ImageComponent || klass == Elements::IframeComponent
        # ensure image always comes first on 2 col layouts
        return 'order-first-md-down pb-4 pb-lg-0'
      end
    end

    def initialize(cols:, feature: false, cell_classes: '', **_kwargs)
      super
      @feature = feature
      @cols = cols

      @cell_classes = cell_classes
    end

    def render?
      cells.any?
    end

    def default_column_classes
      case cols
      when 1
        'col-12'
      when 2
        'col-12 col-lg-6'
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
