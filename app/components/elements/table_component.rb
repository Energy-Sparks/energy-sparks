module Elements
  class TableComponent < ApplicationComponent
    renders_many :rows, ->(**kwargs) {
      RowComponent.new(**kwargs)
    }
    renders_many :head_rows, ->(cells = [], **kwargs) {
      RowComponent.new(**kwargs.merge(header_cells: cells))
    }
    renders_many :body_rows, ->(cells = [], **kwargs) {
      RowComponent.new(**kwargs.merge(cells: cells))
    }
    renders_many :foot_rows, ->(cells = [], **kwargs) {
      RowComponent.new(**kwargs.merge(call: cells))
    }

    class RowComponent < ApplicationComponent
      renders_many :cells, types: {
        cell: {
           renders: ->(*args, **kwargs, &block) { CellComponent.new(*args, **kwargs, &block) },
           as: :cell
        },
        header_cell: {
          renders: ->(*args, **kwargs, &block) { HeaderCellComponent.new(*args, **kwargs, &block) },
          as: :header_cell
        }
      }

      def initialize(header_cells: [], cells: [], **kwargs)
        super
        @header_cells = header_cells
        @cells = cells
      end

      def before_render
        @header_cells.each { |cell| with_header_cell(cell) }
        @cells.each { |cell| with_cell(cell) }
      end

      def call
        tag.tr(class: classes) do
          safe_join(cells)
        end
      end
    end

    class CellComponent < ApplicationComponent
      def initialize(text = nil, **kwargs)
        super
        @options = build_options(kwargs)
        @tag = :td
        @text = text
      end

      def call
        content_tag(@tag, **@options) do
          (content || @text).to_s.html_safe
        end
      end

      protected

      def valid_options
        [:id, :width, :height, :headers, :colspan, :rowspan]
      end

      def build_options(kwargs)
        kwargs.slice(*valid_options).merge({ class: classes })
      end
    end

    class HeaderCellComponent < CellComponent
      def initialize(text = nil, **kwargs)
        super
        validate_scope(kwargs[:scope])
        @tag = :th
      end

      protected

      def valid_options
        super + [:scope, :abbr]
      end

      private

      def valid_scopes
        ['col', 'row', 'colgroup', 'rowgroup']
      end

      def validate_scope(scope)
        raise ArgumentError.new('Invalid scope') if scope && !valid_scopes.include?(scope)
      end
    end
  end
end
