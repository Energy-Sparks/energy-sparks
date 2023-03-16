module Schools
  class Comparison
    attr_reader :school_value, :benchmark_value, :exemplar_value, :unit

    def initialize(school_value:, benchmark_value:, exemplar_value:, unit:, low_is_good: true)
      @school_value = school_value
      @benchmark_value = benchmark_value
      @exemplar_value = exemplar_value
      @unit = unit
      @low_is_good = low_is_good
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
      if exemplar_school?
        :exemplar_school
      elsif benchmark_school?
        :benchmark_school
      else
        :other_school
      end
    end

    def exemplar_school?
      @low_is_good ? @school_value <= @exemplar_value : @school_value >= @exemplar_value
    end

    def benchmark_school?
      if @low_is_good
        @school_value > @exemplar_value && @school_value <= @benchmark_value
      else
        @school_value < @exemplar_value && @school_value >= @benchmark_value
      end
    end
  end
end
