module SchoolGroups
  class CategoriseSchools
    def initialize(schools:)
      @schools = schools
    end

    def categorise_schools
      find_advice_page_school_benchmarks.reduce(init_hash) do |results, school_result|
        r = SchoolResult.new(school_result)
        results[r.fuel_type][r.advice_page_key][r.benchmarked_as] << school_result
        results
      end
    end

    def categorise_schools_for_advice_page(advice_page)
      results_by_benchmark = Hash.new { |h, k| h[k] = [] }

      find_advice_page_school_benchmarks.each do |school_result|
        next unless school_result['advice_page_key'] == advice_page.key
        results_by_benchmark[SchoolResult.new(school_result).benchmarked_as] << school_result
      end

      results_by_benchmark
    end

    def school_categories(advice_page)
      find_advice_page_school_benchmarks.filter_map do |school_result|
        next unless school_result['advice_page_key'] == advice_page.key
        [school_result['school_id'], SchoolResult.new(school_result).benchmarked_as]
      end.to_h
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
        school_group_clusters.name AS cluster_name,
        advice_page_school_benchmarks.benchmarked_as
        FROM advice_page_school_benchmarks
        INNER JOIN advice_pages ON advice_pages.id = advice_page_school_benchmarks.advice_page_id
        INNER JOIN schools ON schools.id = advice_page_school_benchmarks.school_id
        LEFT JOIN school_group_clusters ON school_group_clusters.id = schools.school_group_cluster_id
        WHERE schools.id IN (#{@schools.pluck(:id).join(',')})
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
