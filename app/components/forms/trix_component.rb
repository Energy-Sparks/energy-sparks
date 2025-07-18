module Forms
  class TrixComponent < ApplicationComponent
    attr_reader :form, :field, :charts, :field_kwargs

    def initialize(form:, field:, controls: :default, size: :default, button_size: :default, charts: nil, **kwargs)
      super
      raise ArgumentError, 'Unknown size' if size && !self.class.sizes.include?(size)
      raise ArgumentError, 'Unknown button size' if button_size && !self.class.sizes.include?(button_size)
      raise ArgumentError, 'Unknown controls options' if controls && !self.class.controls.include?(controls)

      @form = form
      @field = field
      @charts = charts
      @field_kwargs = kwargs.except(:id, :classes)
      add_classes(size)
      add_classes("buttons-#{button_size}")
      add_classes('chart-list') if charts&.any?
      add_classes("controls-#{controls}")
    end

    def data_attributes
      { chart_list: charts } if charts
    end

    class << self
      def sizes
        [:default, :large]
      end

      def controls
        [:default, :simple, :advanced]
      end
    end
  end
end
