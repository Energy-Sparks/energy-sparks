module SchoolGroups
  class CategoriseSchools
    def initialize(school_group:, advice_page: baseload_advice_page)
      @school_group = school_group
      @advice_page = advice_page
    end

    def categorise_schools
      exemplar_school = []
      benchmark_school = []
      other_school = []
      not_categorised = []

      @school_group.schools.each do |school|
        case benchmark(school)
        when :other_school
          other_school << school
        when :benchmark_school
          benchmark_school << school
        when :exemplar_school
          exemplar_school << school
        else
          not_categorised << school
        end
      end

      OpenStruct.new(
        exemplar_school: exemplar_school,
        benchmark_school: benchmark_school,
        other_school: other_school
      )
    end

    private

    def benchmark(school)
      aggregate_school = AggregateSchoolService.new(school).aggregate_school
      Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator.generator_for(
        advice_page: @advice_page,
        school: school,
        aggregate_school: aggregate_school
      ).benchmark_school
    rescue
      nil
    end

    def baseload_advice_page
      OpenStruct.new(key: :baseload)
    end
  end
end
