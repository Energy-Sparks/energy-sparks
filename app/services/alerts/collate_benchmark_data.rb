module Alerts
  class CollateBenchmarkData
    def perform(schools = School.process_data)
      benchmarks = {}

      latest_run = BenchmarkResultGenerationRun.order(created_at: :desc).first
      latest_school_runs = latest_run.benchmark_result_school_generation_runs.where(school: schools)
      get_benchmarks_for_latest_run(latest_school_runs, benchmarks)

      benchmarks
    end

    private

    def get_benchmarks_for_latest_run(latest_school_runs, benchmarks)
      latest_school_runs.each do |benchmark_result_school_generation_run|
        school = benchmark_result_school_generation_run.school

        benchmark_result_school_generation_run.benchmark_results.each do |benchmark_result|
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
end
