module Layout
  class GridComponent < ApplicationComponent
    attr_reader :cols, :rows

    renders_many :cells, types: {
      block: { renders: ->(*args, **kwargs, &block) { column_div(Elements::BlockComponent, *args, **kwargs, &block) }, as: :block },
      icon: { renders: ->(*args, **kwargs, &block) { column_div(IconComponent, *args, **kwargs, &block) }, as: :icon },
      image: { renders: ->(*args, **kwargs, &block) { column_div(Elements::ImageComponent, *args, **kwargs, &block) }, as: :image },
      tag: { renders: ->(*args, **kwargs, &block) { column_div(Elements::TagComponent, *args, **kwargs, &block) }, as: :tag },
      prompt_list: { renders: ->(*args, **kwargs, &block) { column_div(PromptListComponent, *args, **kwargs, &block) }, as: :prompt_list },
      stats_card: { renders: ->(*args, **kwargs, &block) { column_div(Cards::StatsComponent, *args, **kwargs, &block) }, as: :stats_card },
      feature_card: { renders: ->(*args, **kwargs, &block) { column_div(Cards::FeatureComponent, *args, **kwargs, &block) }, as: :feature_card },
      testimonial_card: { renders: ->(*args, **kwargs, &block) { column_div(Cards::TestimonialComponent, *args, **kwargs, &block) }, as: :testimonial_card }
    }

    private

    def column_div(component_name, *args, **kwargs, &block)
      kwargs[:classes] = class_names(kwargs[:classes], @component_classes)
      cell_classes = kwargs.delete(:cell_classes)

      tag.div(class: class_names(column_classes, cell_classes, @cell_classes)) do
        render(component_name.new(*args, **kwargs), &block)
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
      end
    end
  end
end
