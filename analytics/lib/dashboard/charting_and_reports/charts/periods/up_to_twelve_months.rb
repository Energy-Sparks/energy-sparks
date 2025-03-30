require_relative '../periods.rb'

module Periods
  class UpToTwelveMonths < PeriodsBase
    # Within the available meter date range, generate a list of 12 months periods
    #
    # Final end date should be last full month of data
    # We then work back exactly 12 months from there
    #
    # The final range can include a partial year, but must only have full months
    #
    # This means partial months at beginning and end of meter time series are ignored
    protected def period_list(first_meter_date = @first_meter_date, last_meter_date = @last_meter_date)
      periods = []
      period_end = last_full_month(last_meter_date) #end of last full month of data
      while period_end >= first_meter_date
        period_start = (period_end - 11.months).beginning_of_month #12 months ago, start of month
        break if period_start < first_meter_date
        periods << new_school_period(period_start, period_end)
        period_end = period_start - 1
      end
      if first_meter_date < period_end
        # start of first full month of data
        period_start = first_full_month(first_meter_date)
        # add partial year if there's more than a month of data
        periods << new_school_period(period_start, period_end) if period_start < period_end
      end
      periods
    end

    def calculate_period_from_offset(offset)
      period_list[offset.magnitude]
    end

    protected def calculate_period_from_date(date)
      period_list.each do |period|
        return period if date.between?(period.start_date, period.end_date)
      end
      nil
    end

    private

    def last_full_month(date)
      if date == date.end_of_month
        date
      else
        #end of last month
        date.beginning_of_month - 1
      end
    end

    def first_full_month(date)
      if date == date.beginning_of_month
        date
      else
        date.end_of_month + 1
      end
    end
  end
end
