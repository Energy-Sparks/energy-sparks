require_relative '../../../../app/services/usage/annual_usage_benchmarks_service'

# For charts configured with:
#
# ```
# inject: :benchmark
# ```
#
# This class will inject additional series based on calculating the usage
# for an Exemplar of Benchmark ('Well Managed') school with similar characteristics
class AggregatorBenchmarks < AggregatorBase
  EXEMPLAR_SCHOOL_NAME = 'Exemplar School'.freeze
  BENCHMARK_SCHOOL_NAME = 'Benchmark (Good) School'.freeze

  def inject_benchmarks
    results.reverse_x_axis

    logger.debug { "Injecting exemplar and well manage schooled benchmark data: for #{results.bucketed_data.keys}" }

    results.x_axis.push(EXEMPLAR_SCHOOL_NAME)
    results.x_axis.push(BENCHMARK_SCHOOL_NAME)

    most_recent_date_range = results.x_axis_bucket_date_ranges.sort_by(&:first).last
    asof_date = most_recent_date_range.last
    datatype = @chart_config[:yaxis_units]

    [Series::MultipleFuels::ELECTRICITY, Series::MultipleFuels::GAS, Series::MultipleFuels::STORAGEHEATERS].each do |fuel_type_str|
      next unless benchmark_required?(fuel_type_str)

      fuel = fuel_type_str == Series::MultipleFuels::STORAGEHEATERS ? :storage_heaters : fuel_type_str.to_sym
      set_benchmark_buckets(
        results.bucketed_data[fuel_type_str],
        benchmark_data(asof_date, fuel, :exemplar_school,  datatype),
        benchmark_data(asof_date, fuel, :benchmark_school, datatype)
      )
    end

    return unless benchmark_required?(Series::MultipleFuels::SOLARPV)

    set_benchmark_buckets(results.bucketed_data[Series::MultipleFuels::SOLARPV], 0.0, 0.0, 0.0)
  end

  private

  def benchmark_required?(fuel_type)
    results.bucketed_data.key?(fuel_type) && results.bucketed_data[fuel_type].is_a?(Array) && results.bucketed_data[fuel_type].sum > 0.0
  end

  def set_benchmark_buckets(bucket, exemplar, regional)
    bucket.push(exemplar)
    bucket.push(regional)
  end

  def benchmark_data(asof_date, fuel_type, benchmark_type, datatype)
    service = Usage::AnnualUsageBenchmarksService.new(school, fuel_type, asof_date)
    benchmarked_usage = service.annual_usage(compare: benchmark_type)
    benchmarked_usage.send(datatype.to_sym)
  end
end
