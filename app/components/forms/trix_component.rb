module Forms
  class TrixComponent < ApplicationComponent
    attr_reader :form, :field, :charts, :required

    def initialize(form:, field:, controls: :default, size: :default, button_size: :default, charts: nil, required: true, **_kwargs)
      super
      raise ArgumentError, 'Unknown size' if size && !self.class.sizes.include?(size)
      raise ArgumentError, 'Unknown button size' if button_size && !self.class.sizes.include?(button_size)

      @form = form
      @field = field
      @charts = charts
      @required = required
      add_classes(size)
      add_classes("buttons-#{button_size}")
      add_classes('chart-list') if charts&.any?
      add_classes("controls-#{controls}")
    end

    def data_attributes
      return { chart_list: charts } if charts
    end

    class << self
      def sizes
        [:default, :large]
      end
    end
  end
end
