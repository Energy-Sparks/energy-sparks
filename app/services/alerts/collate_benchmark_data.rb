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
      I18n.locale == :cy ? :results_cy : :results
    end

    def benchmark_run_date
      @benchmark_run_date ||= @benchmark_run.run_date
    end

    def get_benchmarks_for_latest_run(latest_school_runs, benchmarks)
      latest_school_runs.each do |benchmark_result_school_generation_run|
        school_id = benchmark_result_school_generation_run.school_id

        benchmark_result_school_generation_run.benchmark_results.pluck(result_column).each do |benchmark_result|
          # When collating results we need to collate around benchmark run date not analysis (asof) date
          benchmarks[benchmark_run_date] = { school_id => {} } unless benchmarks.key?(benchmark_run_date)
          benchmarks[benchmark_run_date][school_id] = {} unless benchmarks[benchmark_run_date].key?(school_id)
          benchmarks[benchmark_run_date][school_id] = benchmarks[benchmark_run_date][school_id].merge!(BenchmarkResult.convert_for_processing(benchmark_result))
        end
      end
    end
  end
end
