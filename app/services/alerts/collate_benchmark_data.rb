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

    def result_column
      EnergySparks::FeatureFlags.active?(:json_benchmarks) ? :results : :data
    end

    def get_benchmarks_for_latest_run(latest_school_runs, benchmarks)
      latest_school_runs.each do |benchmark_result_school_generation_run|
        school_id = benchmark_result_school_generation_run.school_id

        benchmark_result_school_generation_run.benchmark_results.pluck(result_column).each do |benchmark_result|
          # When collating results we need to collate around benchmark run date (created_at) not analysis (asof) date
          unless benchmarks.key?(@benchmark_run.created_at)
            benchmarks[@benchmark_run.created_at] = { school_id => {} }
          end
          unless benchmarks[@benchmark_run.created_at].key?(school_id)
            benchmarks[@benchmark_run.created_at][school_id] = {}
          end
          benchmarks[@benchmark_run.created_at][school_id] = benchmarks[@benchmark_run.created_at][school_id].merge!(BenchmarkResult.convert_for_processing(benchmark_result))
        end
      end
    end
  end
end
