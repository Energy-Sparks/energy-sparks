# frozen_string_literal: true

module Usage
  class PeakUsageBenchmarkingService
    def initialize(meter_collection:, asof_date:)
      @meter_collection = meter_collection
      @asof_date = asof_date
    end

    def average_peak_usage_kw(compare: :exemplar_school)
      case compare
      when :benchmark_school
        benchmark_kw
      when :exemplar_school
        exemplar_kw
      else
        raise 'Invalid comparison'
      end
    end

    def estimated_savings(versus: :exemplar_school)
      case versus
      when :benchmark_school
        consumption_above_peak(benchmark_kwh)
      when :exemplar_school
        consumption_above_peak(exemplar_kwh)
      else
        raise 'Invalid comparison'
      end
    end

    private

    def consumption_above_peak(peak_kwh)
      totals = consumption_above_peak_totals(peak_kwh)

      CombinedUsageMetric.new(
        kwh: totals[:kwh],
        £: totals[:£],
        co2: totals[:co2]
      )
    end

    def consumption_above_peak_totals(peak_kwh)
      totals = { kwh: 0.0, £: 0.0, co2: 0.0 }

      full_date_range.each do |date|
        48.times do |hhi|
          kwh = aggregate_meter.amr_data.kwh(date, hhi, :kwh)
          percent_above_exemplar = capped_percent(kwh, peak_kwh)

          next if percent_above_exemplar.nil?

          totals[:kwh]  += percent_above_exemplar * kwh
          totals[:£]    += percent_above_exemplar * aggregate_meter.amr_data.kwh(date, hhi, :£current)
          totals[:co2]  += percent_above_exemplar * aggregate_meter.amr_data.kwh(date, hhi, :co2)
        end
      end

      totals.transform_values { |value| scale_to_year(value) }
    end

    def capped_percent(kwh, peak_kwh)
      return nil if kwh <= peak_kwh

      (kwh - peak_kwh) / kwh
    end

    def aggregate_meter
      @meter_collection.aggregated_electricity_meters
    end

    def full_date_range
      start_date = [@asof_date - 364, aggregate_meter.amr_data.start_date].max
      start_date..@asof_date
    end

    def scale_to_year(val)
      scale_factor = 365.0 / (full_date_range.last - full_date_range.first + 1)
      val * scale_factor
    end

    def benchmark_kw
      BenchmarkMetrics.benchmark_peak_kw(pupils, school_type)
    end

    def benchmark_kwh
      @benchmark_kwh ||= benchmark_kw / 2.0
    end

    def exemplar_kw
      BenchmarkMetrics.exemplar_peak_kw(pupils, school_type)
    end

    def exemplar_kwh
      @exemplar_kwh ||= exemplar_kw / 2.0
    end

    def school_type
      @meter_collection.school_type
    end

    def pupils
      aggregate_meter.meter_number_of_pupils(@meter_collection, start_date, end_date)
    end

    def start_date
      @asof_date - 365
    end

    def end_date
      @asof_date
    end

    def average_school_day_peak_usage_kw
      @average_school_day_peak_usage_kw ||= meter_collection_peak_usage_calculation.average_peak_kw
    end

    def meter_collection_peak_usage_calculation
      Usage::PeakUsageCalculationService.new(
        meter_collection: @meter_collection,
        asof_date: @asof_date
      )
    end
  end
end
