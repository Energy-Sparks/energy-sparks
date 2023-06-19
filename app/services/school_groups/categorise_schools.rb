module SchoolGroups
  class CategoriseSchools
    def initialize(school_group:)
      @school_group = school_group
    end

    def categorise_schools
      find_advice_page_school_benchmarks.reduce(init_hash) do |results, school_result|
        r = SchoolResult.new(school_result)
        results[r.fuel_type][r.advice_page_key][r.benchmarked_as] << school_result
        results
      end
    end

    private

    def find_advice_page_school_benchmarks
      sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
      AdvicePageSchoolBenchmark.connection.select_all(sanitized_query)
    end

    def query
      <<-SQL.squish
        SELECT
        advice_pages.key AS advice_page_key,
        advice_pages.fuel_type AS fuel_type,
        schools.id AS school_id,
        schools.slug AS school_slug,
        schools.name AS school_name,
        advice_page_school_benchmarks.benchmarked_as
        FROM advice_page_school_benchmarks
        INNER JOIN advice_pages ON advice_pages.id = advice_page_school_benchmarks.advice_page_id
        INNER JOIN schools ON schools.id = advice_page_school_benchmarks.school_id
        WHERE schools.school_group_id = #{@school_group.id}
        AND schools.active = true
        AND schools.visible = true
        ORDER BY advice_pages.key, schools.name;
      SQL
    end

    def init_hash
      Hash.new do |results, fuel_type|
        results[fuel_type] = Hash.new do |advice_pages, advice_page_key|
          advice_pages[advice_page_key] = Hash.new do |benchmarks, benchmarked_as|
            benchmarks[benchmarked_as] = []
          end
        end
      end
    end
  end

  class SchoolResult
    attr_reader :result

    def initialize(school_result)
      @result = school_result
    end

    def fuel_type
      @fuel_type ||= result['fuel_type'] ? AdvicePage.fuel_types.key(result['fuel_type']).to_sym : :other
    end

    def advice_page_key
      @advice_page_key ||= result['advice_page_key'].to_sym
    end

    def benchmarked_as
      @benchmarked_as ||= AdvicePageSchoolBenchmark.benchmarked_as.key(result['benchmarked_as']).to_sym
    end
  end
end
