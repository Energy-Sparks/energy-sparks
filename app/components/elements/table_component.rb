module Elements
  class TableComponent < ApplicationComponent
    renders_many :headers, ->(**kwargs, &block) {
      HeaderComponent.new(**kwargs, &block)
    }

    renders_many :rows, ->(**kwargs, &block) {
      RowComponent.new(**kwargs, &block)
    }

    def initialize(classes: 'table table-hover', **_kwargs)
      super
      @classes = classes
    end

    def call
      tag.table(class: @classes) do
        safe_join([
          render_headers,
          render_rows
        ].compact)
      end
    end

    private

    def render_headers
      return if headers.empty?

      tag.thead do
        tag.tr do
          safe_join(headers.map { |h| render h })
        end
      end
    end

    def render_rows
      tag.tbody do
        safe_join(rows.map { |r| render r })
      end
    end

    class HeaderComponent < ApplicationComponent
      renders_many :cells, ->(text = nil, scope: nil, **kwargs) {
        HeaderCellComponent.new(text: text, scope: scope, **kwargs)
      }

      def initialize(**_kwargs, &block)
        super
        @block = block
      end

      def before_render
        instance_exec(self, &@block) if @block
      end

      def call
        safe_join(cells.map { |c| render c })
      end
    end

    class CellComponent < ApplicationComponent
      def initialize(text:, **_kwargs)
        super
        @text = text
      end

      def call
        tag.td(@text)
      end
    end

    class HeaderCellComponent < CellComponent
      def initialize(text:, scope: 'col', **kwargs)
        super(text: text, **kwargs)
        @scope = scope
      end

      def call
        tag.th(@text, scope: @scope)
      end
    end

    class RowComponent < ApplicationComponent
      renders_many :cells, ->(text = nil, **kwargs) {
        CellComponent.new(text: text, **kwargs)
      }

      def initialize(row_scope: nil, **_kwargs, &block)
        super
        @row_scope = row_scope
        @block = block
      end

      def before_render
        instance_exec(self, &@block) if @block
      end

      def call
        tag.tr do
          safe_join(
            [@row_scope && tag.th(@row_scope, scope: 'row')].compact +
            cells.map { |c| render c }
          )
        end
      end
    end
  end
end
