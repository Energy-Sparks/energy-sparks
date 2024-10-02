module Benchmarking
  class BenchmarkContentManager
    attr_reader :asof_date
    def initialize(asof_date)
      @asof_date = asof_date
    end

    def available_pages(school_ids: nil, filter: nil)
      # TODO(PH, 1Nov2019) filter list where not relevant e.g. gas only content for Highland Schools
      BenchmarkManager.available_pages({filter_out: :dont_make_available_directly})
    end

    #Used by application
    def structured_pages(school_ids: nil, filter: nil, user_type: nil)
      # TODO(PH, 1Nov2019) filter list where not relevant e.g. gas only content for Highland Schools
      BenchmarkManager.structured_pages(user_type)
    end

    def benchmark_dates(_page_name)
      [asof_date]
    end

    def front_end_content(benchmark_database, page_name, school_ids: nil, filter: nil)
      content = content_handler(benchmark_database, page_name)
      content.front_end_content(school_ids: school_ids, filter: filter)
    end

    #Used by application
    def content(benchmark_database, page_name, school_ids: nil, filter: nil, user_type: nil, online: false)
      content = content_handler(benchmark_database, page_name, online)
      content.content(school_ids: school_ids, filter: filter, user_type: user_type)
    end

    private

    def content_handler(benchmark_database, page_name, online)
      chart_table_config = BenchmarkManager.chart_table_config(page_name)
      content_class = chart_table_config.key?(:benchmark_class) ? chart_table_config[:benchmark_class] : BenchmarkContentBase
      content_class.new(benchmark_database, asof_date, page_name, chart_table_config, online)
    end
  end
end
