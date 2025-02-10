class GridComponent < ApplicationComponent
  attr_reader :cols, :rows, :column_classes

  renders_many :columns, types: {
    block: {
      renders: ->(*args, **kwargs) { BlockComponent.new(*args, **merge_classes(kwargs)) },
      as: :block
    },
    icon: { # not sure this is useful but put it here for demo purposes
      renders: ->(*args, **kwargs) { IconComponent.new(*args, **merge_classes(kwargs)) },
      as: :icon
    },
    image: {
      renders: ->(*args, **kwargs) { ImageComponent.new(*args, **merge_classes(kwargs)) },
      as: :image
    },
    prompt_list: {
      renders: ->(*args, **kwargs) { PromptListComponent.new(*args, **merge_classes(kwargs)) },
      as: :prompt_list
    }
  }

  def initialize(cols:, rows: 1, column_classes: '', component_classes: '', id: nil, classes: '')
    super(id: id, classes: ['grid-component', classes])

    @cols = cols
    @rows = rows

    @column_classes = token_list(base_column_classes, column_classes)
    @component_classes = token_list(component_classes)
    @column_classes_map = {}
  end

  def with_column(type = 'block', *args, column_classes: '', **kwargs, &block)
    kwargs[:classes] = token_list(kwargs[:classes], @component_classes)
    slot = public_send("with_#{type}", *args, **kwargs, &block)
    @column_classes_map[slot] = token_list(@column_classes, column_classes)
    slot
  end

  def render?
    columns.any?
  end

  private

  def merge_classes(kwargs)
    kwargs.except(:column_classes).merge(classes: token_list(kwargs[:classes], @component_classes))
  end

  def base_column_classes
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
