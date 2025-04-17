module Schools
  class AnalysisDates
    def initialize(school, fuel_type)
      @school = school
      @fuel_type = fuel_type
    end

    def analysis_date
      case @fuel_type&.to_sym
      when :gas, :electricity, :storage_heater
        analysis_end_date
      else
        Time.zone.today
      end
    end

    # as used in usage charts
    def usage_chart_dates
      {
        earliest_reading:  analysis_start_date,
        last_reading:  analysis_end_date,
      }
    end

    def analysis_start_date
      @analysis_start_date ||= @school.configuration.meter_start_date(@fuel_type)
    end

    def analysis_end_date
      @analysis_end_date ||= @school.configuration.meter_end_date(@fuel_type)
    end

    alias_method :start_date, :analysis_start_date
    alias_method :end_date, :analysis_end_date

    def one_year_before_end
      analysis_end_date - 1.year
    end

    def one_years_data?
      (analysis_end_date - 364) >= analysis_start_date
    end

    # FIXME BaseLongTerm
    # _analysis_comparison
    # group_by_week_electricity_versus_benchmark
    def last_full_week_start_date_long_term_usage
      if one_years_data?
        last_full_week_start_date
      else
        analysis_start_date.end_of_week
      end
    end

    # for charts that use the last full week
    # beginning of the week is Sunday
    #
    # FIXME BaseOutOfHours
    # _holidays.html.erb
    # alert_group_by_week_electricity_14_months
    # alert_group_by_week_gas_14_months
    # management_dashboard_group_by_week_gas
    # management_dashboard_group_by_week_electricity
    def last_full_week_start_date_out_of_hours
      (analysis_end_date - 13.months).beginning_of_week - 1
    end

    # for charts that use the last full week
    # TODO BaseLongTerm
    def last_full_week_start_date
      analysis_end_date.prev_year.end_of_week
    end

    # for charts that use the last full week
    # end of the week is Saturday
    # TODO BaseOutOfHours
    def last_full_week_end_date
      analysis_end_date.end_of_week - 1
    end

    def recent_data
      analysis_date > (Time.zone.today - 30.days)
    end

    def months_of_data
      ((analysis_end_date - analysis_start_date).to_f / 365 * 12).floor
    end

    def months_analysed
      months = months_of_data
      months > 12 ? 12 : months
    end

    def fixed_academic_year_end
      DateService.fixed_academic_year_end(analysis_end_date)
    end

    # At what date will we have one years data
    def date_when_one_years_data
      date_when_enough_data_available(365)
    end

    # At what date will we have two years of data
    def date_when_two_years_data
      date_when_enough_data_available(365 * 2)
    end

    def days_of_data
      (analysis_date - analysis_start_date) + 1
    end

    # Estimate when we will have enough data available
    def date_when_enough_data_available(days_required)
      return nil if days_of_data >= days_required

      extra_days_needed = days_required - days_of_data
      analysis_date + extra_days_needed
    end
  end
end
