# not directly called by the front end
class AlertEconomicTariffCalculations
  attr_reader :school, :meter

  # should work on aggregate and real meters but not tested
  # and the calculations are different
  def initialize(school, meter)
    @school = school
    @meter = meter
  end

  def changed_this_year?
    sd = [start_date, end_date - 365].max
    !meter.meter_tariffs.tariff_change_dates_in_period(sd, end_date).empty?
  end

  def changed_previous_year?
    end_previous_year_date = end_date - 365 - 1
    return nil if start_date > end_previous_year_date

    sd = [start_date, end_previous_year_date - 365].max
    !meter.meter_tariffs.tariff_change_dates_in_period(sd, end_previous_year_date).empty?
  end

  def last_tariff_change_compared_with_remainder_of_last_year_percent
    return nil if last_tariff_change_date.nil?

    sd = [start_date, end_date - 365].max

    last_change_date_this_year = meter.meter_tariffs.last_tariff_change_date(sd, end_date)
    return nil if last_change_date_this_year.nil? || last_change_date_this_year - 1 < start_date

    latest_blended_rate_£_per_kwh         = meter.amr_data.blended_rate(:kwh, :£, last_change_date_this_year, end_date)
    remainder_year_blended_rate_£_per_kwh = meter.amr_data.blended_rate(:kwh, :£, sd, last_change_date_this_year - 1)

    latest_blended_rate_£_per_kwh / remainder_year_blended_rate_£_per_kwh
  end

  def last_tariff_change_date
    meter.meter_tariffs.last_tariff_change_date
  end

  private

  def start_date
    @meter.amr_data.start_date
  end

  def end_date
    @meter.amr_data.end_date
  end
end
