module Forms
  class TrixComponent < ApplicationComponent
    attr_reader :form, :field, :charts, :size

    def initialize(form:, field:, size: :default, charts: nil, **_kwargs)
      super
      raise ArgumentError, 'Unknown badge style' if size && !self.class.sizes.include?(size)
      @size = size
      @form = form
      @field = field
      @charts = charts
      add_classes(@size)
      add_classes('chart-list') if charts&.any?
    end

    class << self
      def sizes
        [:default, :large]
      end
    end
  end
end
