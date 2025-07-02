module Elements
  class TableComponent < ApplicationComponent
    renders_many :rows, ->(**kwargs) {
      RowComponent.new(**kwargs)
    }
    renders_many :head_rows, ->(**kwargs) {
      RowComponent.new(**kwargs)
    }
    renders_many :body_rows, ->(**kwargs) {
      RowComponent.new(**kwargs)
    }
    renders_many :foot_rows, ->(**kwargs) {
      RowComponent.new(**kwargs)
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
          content || @text
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
