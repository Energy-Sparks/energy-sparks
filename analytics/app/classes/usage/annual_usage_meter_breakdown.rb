# frozen_string_literal: true

module Usage
  class AnnualUsageMeterBreakdown
    attr_reader :start_date, :end_date

    def initialize(meter_breakdown:, percentage_change_last_year:, start_date:, end_date:)
      @meter_breakdown = meter_breakdown
      @percentage_change_last_year = percentage_change_last_year
      @start_date = start_date
      @end_date = end_date
    end

    def meters
      @meter_breakdown.keys
    end

    def usage(mpan_mprn)
      @meter_breakdown[mpan_mprn][:usage]
    end

    def annual_percent_change(mpan_mprn)
      @meter_breakdown[mpan_mprn][:annual_change]
    end

    def total_usage
      @total_usage ||= CombinedUsageMetric.new(
        kwh: total_kwh,
        £: total_£,
        co2: total_co2,
        percent: 1.0
      )
    end

    def total_annual_percent_change
      @percentage_change_last_year
    end

    private

    def total_kwh
      @meter_breakdown.map { |_meter, usage| usage[:usage].kwh || 0.0 }.sum
    end

    def total_£
      @meter_breakdown.map { |_meter, usage| usage[:usage].£ || 0.0 }.sum
    end

    def total_co2
      @meter_breakdown.map { |_meter, usage| usage[:usage].co2 || 0.0 }.sum
    end
  end
end
