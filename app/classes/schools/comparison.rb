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
      @school_value.present? && @exemplar_value.present? && @unit.present?
    end

    def category
      @category ||= categorise_school
    end

    private

    def categorise_school
      return :other_school if @school_value.nil? || @benchmark_value.nil? || @exemplar_value.nil?
      if @school_value <= @exemplar_value
        :exemplar_school
      elsif @school_value > @exemplar_value &&
            @school_value <= @benchmark_value
        :benchmark_school
      else
        :other_school
      end
    end
  end
end
