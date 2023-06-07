module SchoolGroups
  class CategoriseSchools
    def initialize(school_group:)
      @school_group = school_group
    end

    def categorise_schools
      benchmarks_grouped_by_advice_page.each_with_object({}) do |(advice_page_key, school_results), categorised_schools|
        categorised_schools[advice_page_key.to_sym] = school_results.group_by do |school_result|
          AdvicePageSchoolBenchmark.benchmarked_as.key(school_result['benchmarked_as']).to_sym
        end
      end
    end

    private

    def benchmarks_grouped_by_advice_page
      find_advice_page_school_benchmarks.group_by do |advice_page_school_benchmark|
        advice_page_school_benchmark['advice_page_key'].to_sym
      end
    end

    def find_advice_page_school_benchmarks
      sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
      AdvicePageSchoolBenchmark.connection.select_all(sanitized_query)
    end

    def query
      <<-SQL.squish
        select
        advice_pages.key as advice_page_key,
        schools.id as school_id,
        schools.slug as school_slug,
        schools.name as school_name,
        advice_page_school_benchmarks.benchmarked_as
        from advice_page_school_benchmarks
        inner join advice_pages on advice_pages.id = advice_page_school_benchmarks.advice_page_id
        inner join schools on schools.id = advice_page_school_benchmarks.school_id
        where schools.school_group_id = #{@school_group.id}
        order by advice_pages.key;
      SQL
    end
  end
end
