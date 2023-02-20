module Schools
  class Comparison
    attr_reader :school_value, :benchmark_value, :exemplar_value, :unit

    def initialize(school_value:, benchmark_value:, exemplar_value:, unit:)
      @school_value = school_value
      @benchmark_value = benchmark_value
      @exemplar_value = exemplar_value
      @unit = unit
    end

    def valid?
      @school_value.present? &&
        @benchmark_value.present? &&
        @exemplar_value.present? &&
        @unit.present?
    end

    def category
      @category ||= categorise_school
    end

    private

    def categorise_school
      return :other if @school_value.nil? || @benchmark_value.nil? || @exemplar_value.nil?
      if @school_value <= @exemplar_value
        :exemplar
      elsif @school_value > @exemplar_value &&
            @school_value <= @benchmark_value
        :benchmark
      else
        :other
      end
    end
  end
end
