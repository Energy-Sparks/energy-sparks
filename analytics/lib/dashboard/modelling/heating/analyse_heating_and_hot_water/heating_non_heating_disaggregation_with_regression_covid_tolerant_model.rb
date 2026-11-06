require_relative 'heating_non_heating_disaggregation_with_regression_model'

module AnalyseHeatingAndHotWater
  # as per the basic regression model but gets its summer data from 2019
  # to avoid 2020 COVID period when summer usage was 'strange' at some schools
  class HeatingNonHeatingDisaggregationWithRegressionCOVIDTolerantModel < HeatingNonHeatingDisaggregationWithRegressionModel
    def self.type; :temperature_sensitive_regression_model_covid_tolerant end

    private

    def occupied_school_days(period, list_of_months)
      school_days = super(period, list_of_months)
      if meter_data_available_in_2019?(list_of_months) && all_in_covid_lock_down(school_days)
        school_days = occupied_school_days_2019(list_of_months)
      end
      school_days
    end

    def all_in_covid_lock_down(days)
      days.all? { |date| DateTimeHelper.covid_lockdown_date?(date) }
    end

    def meter_data_available_in_2019?(list_of_months)
      @meter.amr_data.start_date <= first_day_of_months(list_of_months) &&
      @meter.amr_data.end_date   >= last_day_of_months(list_of_months)
    end

    def occupied_school_days_2019(list_of_months)
      (first_day_of_months(list_of_months)..last_day_of_months(list_of_months)).map do |date|
        occupied?(date) && list_of_months.include?(date.month) ? date : nil
      end.compact
    end

    def first_day_of_months(list_of_months)
      Date.new(2019, list_of_months.min, 1)
    end

    def last_day_of_months(list_of_months)
      DateTimeHelper.last_day_of_month(Date.new(2019, list_of_months.max, 1))
    end
  end
end
