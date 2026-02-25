# frozen_string_literal: true

module Usage
  class UsageBreakdown
    attr_reader :holiday, :school_day_closed, :school_day_open, :weekend, :out_of_hours, :community

    def initialize(
      holiday:,
      school_day_closed:,
      school_day_open:,
      weekend:,
      out_of_hours:,
      community:,
      fuel_type:
    )
      @holiday = holiday
      @school_day_closed = school_day_closed
      @school_day_open = school_day_open
      @weekend = weekend
      @out_of_hours = out_of_hours
      @community = community
      @fuel_type = fuel_type
    end

    def total
      CombinedUsageMetric.new(
        kwh: periods_total(:kwh),
        co2: periods_total(:co2),
        £: periods_total(:£)
      )
    end

    private

    def periods_total(metric)
      [@holiday, @weekend, @school_day_open, @school_day_closed, @community].sum { |period| period.public_send(metric) }
    end
  end
end
