class GridComponent < ApplicationComponent
  attr_reader :cols, :rows, :col_classes, :block_classes

  renders_many :blocks, 'BlockComponent'

  def initialize(cols:, rows: 1, col_classes: '', block_classes: '', id: nil, classes: '')
    super(id: id, classes: ['grid-component', classes])

    @cols = cols
    @rows = rows

    @col_classes = token_list(column_classes, col_classes)
    @block_classes = block_classes
  end

  def render?
    blocks.any?
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
    def initialize(id: nil, classes: '', col_classes: '')
      super(id: id, classes: classes)
      @col_classes = col_classes
    end

    def call
      content
    end
  end
end
