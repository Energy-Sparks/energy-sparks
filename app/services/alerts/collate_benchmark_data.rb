module Alerts
  class CollateBenchmarkData
    def initialize(benchmark_run)
      @benchmark_run = benchmark_run
    end

    def perform(schools = School.process_data)
      benchmarks = {}

      latest_school_runs = @benchmark_run.benchmark_result_school_generation_runs.includes(:benchmark_results).where(school: schools).order(id: :asc)
      get_benchmarks_for_latest_run(latest_school_runs, benchmarks)

      benchmarks
    end

    private

    def get_benchmarks_for_latest_run(latest_school_runs, benchmarks)
      latest_school_runs.each do |benchmark_result_school_generation_run|
        school_id = benchmark_result_school_generation_run.school_id

        benchmark_result_school_generation_run.benchmark_results.pluck(:asof, :data).each do |benchmark_result|
          unless benchmarks.key?(benchmark_result[0])
            benchmarks[benchmark_result[0]] = { school_id => {} }
          end
          unless benchmarks[benchmark_result[0]].key?(school_id)
            benchmarks[benchmark_result[0]][school_id] = {}
          end
          benchmarks[benchmark_result[0]][school_id] = benchmarks[benchmark_result[0]][school_id].merge!(benchmark_result[1])
        end
      end
    end
  end
end
