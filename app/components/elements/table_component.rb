module Elements
  class TableComponent < ApplicationComponent
    renders_many :header_rows, ->(**kwargs) {
      RowComponent.new(**kwargs)
    }
    renders_many :rows, ->(**kwargs) {
      RowComponent.new(**kwargs)
    }
    renders_many :footer_rows, ->(**kwargs) {
      RowComponent.new(**kwargs)
    }

    def initialize(classes: 'table', **_kwargs)
      super
    end

    private

    class RowComponent < ApplicationComponent
      renders_many :cells, types: {
        cell: {
           renders: ->(*args, **kwargs, &block) { CellComponent.new(:td, *args, **kwargs, &block) },
           as: :cell
        },
        header_cell: {
          renders: ->(*args, **kwargs, &block) { HeaderCellComponent.new(:th, *args, **kwargs, &block) },
          as: :header_cell
        }
      }

      def initialize(**_kwargs)
        super
      end

      def call
        tag.tr(class: classes) do
          safe_join(cells)
        end
      end
    end

    class CellComponent < ApplicationComponent
      def initialize(tag = :td, text = nil, **kwargs)
        super
        @tag = tag
        @text = text
        @kwargs = kwargs.except(:classes).merge(id: id, class: classes)
      end

      def call
        content_tag(@tag, **@kwargs) do
          content || @text
        end
      end
    end

    class HeaderCellComponent < CellComponent
      def initialize(tag = :th, text = nil, scope: nil, **kwargs)
        raise ArgumentError, "Invalid scope: #{scope}. Scope must be 'col' or 'row'." if scope && scope != 'col' && scope != 'row'
        super
      end
    end
  end
end
