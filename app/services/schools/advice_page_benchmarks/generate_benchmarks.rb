module Schools
  module AdvicePageBenchmarks
    class GenerateBenchmarks
      def initialize(school:, aggregate_school:)
        @school = school
        @aggregate_school = aggregate_school
      end

      def generate!
        AdvicePage.all.each do |advice_page|
          generator = SchoolBenchmarkGenerator.generator_for(advice_page: advice_page, school: @school, aggregate_school: @aggregate_school)
          generator.perform if generator.present?
        end
      end
    end
  end
end
