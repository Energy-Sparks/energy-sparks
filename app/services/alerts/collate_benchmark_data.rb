module Alerts
  class CollateBenchmarkData
    def perform
      benchmarks = {}

      School.process_data.each do |school|
        get_benchmarks_for(school, benchmarks)
      end

      benchmarks
    end

    private

    def get_benchmarks_for(school, benchmarks)
      school.latest_benchmark_results.each do |benchmark_result|
        unless benchmarks.key?(benchmark_result.asof)
          benchmarks[benchmark_result.asof] = { school.id => {} }
        end
        unless benchmarks[benchmark_result.asof].key?(school.id)
          benchmarks[benchmark_result.asof][school.id] = {}
        end
        benchmarks[benchmark_result.asof][school.id] = benchmarks[benchmark_result.asof][school.id].merge(benchmark_result.data)
      end
    end
  end
end
