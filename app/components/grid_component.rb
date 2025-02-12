class GridComponent < ApplicationComponent
  attr_reader :cols, :rows

  renders_many :cells, types: {
    block: { renders: ->(*args, **kwargs, &block) { column_div(BlockComponent, *args, **kwargs, &block) }, as: :block },
    icon: { renders: ->(*args, **kwargs, &block) { column_div(IconComponent, *args, **kwargs, &block) }, as: :icon },
    image: { renders: ->(*args, **kwargs, &block) { column_div(ImageComponent, *args, **kwargs, &block) }, as: :image },
    prompt_list: { renders: ->(*args, **kwargs, &block) { column_div(PromptListComponent, *args, **kwargs, &block) }, as: :prompt_list }
  }

  private

  def column_div(component_name, *args, **kwargs, &block)
    kwargs[:classes] = token_list(kwargs[:classes], @component_classes)
    extra_cell_classes = kwargs.delete(:cell_classes)

    tag.div(class: token_list(column_classes, extra_cell_classes, @cell_classes)) do
      render(component_name.new(*args, **kwargs), &block)
    end
  end

  def initialize(cols:, rows: 1, cell_classes: '', component_classes: '', id: nil, classes: '')
    super(id: id, classes: ['grid-component', classes])

    @cols = cols
    @rows = rows

    @cell_classes = cell_classes
    @component_classes = component_classes
  end

  def render?
    cells.any?
  end

  private

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

  class BlockComponent < ApplicationComponent
    def initialize(id: '', classes: '')
      super(id: id, classes: classes)
    end

    def call
      @classes ? tag.div(class: @classes) { content } : content
    end
  end

  class ImageComponent < ApplicationComponent
    def initialize(source, id: '', classes: '')
      super(id: id, classes: classes)
      @source = source
    end

    def call
      tag.img(src: image_path(@source), class: @classes)
    end
  end
end
