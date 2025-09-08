# probably due to be replaced by a fixed charge per day from April 2023
#
class TNUOSCharges < MaxMonthlyDemandChargesBase
  class MissingTNUoSDataForThisYear < StandardError; end

  YEAR_18_19 = Date.new(2018, 4, 1)..Date.new(2019, 3, 31)
  YEAR_19_20 = Date.new(2019, 4, 1)..Date.new(2020, 3, 31)
  YEAR_20_21 = Date.new(2020, 4, 1)..Date.new(2021, 3, 31)
  YEAR_21_22 = Date.new(2021, 4, 1)..Date.new(2022, 3, 31)
  FINANCIAL_YEARS = [YEAR_18_19, YEAR_19_20, YEAR_20_21, YEAR_21_22]
  TRIAD_DATETIMES = {
    YEAR_20_21 => [
        DateTime.new(2020, 12,  7, 17,  0, 0),
        DateTime.new(2021,  1,  7, 17, 30, 0),
        DateTime.new(2021,  2, 10, 18,  0, 0)
    ],
  }

  # https://www.nationalgrideso.com/charging/transmission-network-use-system-tnuos-charges
  FINAL_TNUOS_RATES = {
    YEAR_18_19 => [
      { zone: 1, name: 'Northern Scotland', rate_£_per_kw: 26.304232, nhh: 3.509185},
      { zone: 2, name: 'Southern Scotland', rate_£_per_kw: 29.070427, nhh: 3.91834},
      { zone: 3, name: 'Northern', rate_£_per_kw: 37.816827, nhh: 4.999041},
      { zone: 4, name: 'North West', rate_£_per_kw: 43.806241, nhh: 5.881985},
      { zone: 5, name: 'Yorkshire', rate_£_per_kw: 44.073211, nhh: 5.785198},
      { zone: 6, name: 'N Wales & Mersey', rate_£_per_kw: 45.512765, nhh: 5.928967},
      { zone: 7, name: 'East Midlands', rate_£_per_kw: 47.501489, nhh: 6.345087},
      { zone: 8, name: 'Midlands', rate_£_per_kw: 48.796991, nhh: 6.732502},
      { zone: 9, name: 'Eastern', rate_£_per_kw: 49.428549, nhh: 7.157677},
      { zone: 10, name: 'South Wales', rate_£_per_kw: 45.80441, nhh: 5.552697},
      { zone: 11, name: 'South East', rate_£_per_kw: 52.110398, nhh: 7.713198},
      { zone: 12, name: 'London', rate_£_per_kw: 54.906683, nhh: 6.10617},
      { zone: 13, name: 'Southern', rate_£_per_kw: 53.419807, nhh: 7.317489},
      { zone: 14, name: 'South Western', rate_£_per_kw: 51.86752, nhh: 7.560093},
    ],
    YEAR_19_20 => [
      { zone: 1, name: 'Northern Scotland', rate_£_per_kw: 20.97127, nhh: 2.82045},
      { zone: 2, name: 'Southern Scotland', rate_£_per_kw: 30.755392, nhh: 4.026035},
      { zone: 3, name: 'Northern', rate_£_per_kw: 41.026683, nhh: 5.213833},
      { zone: 4, name: 'North West', rate_£_per_kw: 47.831581, nhh: 6.202276},
      { zone: 5, name: 'Yorkshire', rate_£_per_kw: 48.039318, nhh: 6.116328},
      { zone: 6, name: 'N Wales & Mersey', rate_£_per_kw: 49.345368, nhh: 6.22376},
      { zone: 7, name: 'East Midlands', rate_£_per_kw: 51.43977, nhh: 6.738557},
      { zone: 8, name: 'Midlands', rate_£_per_kw: 52.928066, nhh: 6.977433},
      { zone: 9, name: 'Eastern', rate_£_per_kw: 53.788327, nhh: 7.496688},
      { zone: 10, name: 'South Wales', rate_£_per_kw: 49.725642, nhh: 5.873287},
      { zone: 11, name: 'South East', rate_£_per_kw: 56.11085, nhh: 7.945653},
      { zone: 12, name: 'London', rate_£_per_kw: 59.175788, nhh: 6.291396},
      { zone: 13, name: 'Southern', rate_£_per_kw: 57.338781, nhh: 7.586023},
      { zone: 14, name: 'South Western', rate_£_per_kw: 55.686678, nhh: 7.767486},
    ],
    YEAR_20_21 => [
      { zone: 1, name: 'Northern Scotland', rate_£_per_kw: 21.126849, nhh: 2.742642},
      { zone: 2, name: 'Southern Scotland', rate_£_per_kw: 28.760295, nhh: 3.528995},
      { zone: 3, name: 'Northern', rate_£_per_kw: 40.022002, nhh: 4.768367},
      { zone: 4, name: 'North West', rate_£_per_kw: 46.674676, nhh: 5.735191},
      { zone: 5, name: 'Yorkshire', rate_£_per_kw: 47.83468, nhh: 5.645414},
      { zone: 6, name: 'N Wales & Mersey', rate_£_per_kw: 48.904955, nhh: 5.811644},
      { zone: 7, name: 'East Midlands', rate_£_per_kw: 51.387929, nhh: 6.281123},
      { zone: 8, name: 'Midlands', rate_£_per_kw: 52.648445, nhh: 6.525494},
      { zone: 9, name: 'Eastern', rate_£_per_kw: 53.48845, nhh: 6.99422},
      { zone: 10, name: 'South Wales', rate_£_per_kw: 50.613794, nhh: 5.594905},
      { zone: 11, name: 'South East', rate_£_per_kw: 56.501849, nhh: 7.511337},
      { zone: 12, name: 'London', rate_£_per_kw: 59.267002, nhh: 5.828242},
      { zone: 13, name: 'Southern', rate_£_per_kw: 57.772417, nhh: 7.136303},
      { zone: 14, name: 'South Western', rate_£_per_kw: 57.020402, nhh: 7.608806},
    ],
    YEAR_21_22 => [
      { zone: 1, name: 'Northern Scotland', rate_£_per_kw: 20.376396, nhh: 2.723726},
      { zone: 2, name: 'Southern Scotland', rate_£_per_kw: 29.300172, nhh: 3.712996},
      { zone: 3, name: 'Northern', rate_£_per_kw: 41.444048, nhh: 5.139134},
      { zone: 4, name: 'North West', rate_£_per_kw: 48.036551, nhh: 6.039881},
      { zone: 5, name: 'Yorkshire', rate_£_per_kw: 48.696198, nhh: 5.963751},
      { zone: 6, name: 'N Wales & Mersey', rate_£_per_kw: 49.452722, nhh: 6.060647},
      { zone: 7, name: 'East Midlands', rate_£_per_kw: 52.428151, nhh: 6.641922},
      { zone: 8, name: 'Midlands', rate_£_per_kw: 53.959972, nhh: 6.937534},
      { zone: 9, name: 'Eastern', rate_£_per_kw: 54.283935, nhh: 7.355652},
      { zone: 10, name: 'South Wales', rate_£_per_kw: 56.236808, nhh: 6.514291},
      { zone: 11, name: 'South East', rate_£_per_kw: 56.772103, nhh: 7.73898},
      { zone: 12, name: 'London', rate_£_per_kw: 59.18635, nhh: 6.378699},
      { zone: 13, name: 'Southern', rate_£_per_kw: 58.865203, nhh: 7.574864},
      { zone: 14, name: 'South Western', rate_£_per_kw: 61.676796, nhh: 8.488355},
    ],
  }
  # guesswork, https://en.wikipedia.org/wiki/Meter_Point_Administration_Number map
  TNUOS_ZONES_TO_MPAN_REGION_MAP = {
     1 => 17,
     2 => 18,
     3 => 15,
     4 => 16, # ? Northern v. North west
     5 => 23,
     6 => 13,
     7 => 11,
     8 => 14, # Midlands versus West midlands?
     9 => 10,
    10 => 21,
    11 => 19,
    12 => 12,
    13 => 20,
    14 => 22
  }

  def cost(date, mpan)
    zone = tnuos_zone(mpan)
    tnuos_rate = rate(date, zone)
    max_kw = max_demand_for_month_kw(date, @amr_data)
    # its not clear whether this is an EDF specific calculation
    # but its used as a running calculation as a proxy estimate
    # for the real triad based calculation, this is then calculated
    # at the end of March when all national grid peak demand triad data is available
    # and an adjustment is applied between the estimate based on the 85% figure
    # and the real values see the 'EDF Triad Charge Reconciliation' document
    # its not clear what the 12.0 is?
    kw = max_kw * 0.85 / 12.0
    tnuos_rate * kw / DateTimeHelper.days_in_month(date)
  end

  private

  def rate(date, zone)
    tnuos_info = final_tnuos_rate(date)
    cost_for_region_info = tnuos_info.select { |data| data[:zone] == zone }[0]
    cost_for_region_info[:rate_£_per_kw]
  end

  def final_tnuos_rate(date)
    years = FINAL_TNUOS_RATES.select { |date_range, _data| date >= date_range.first && date <= date_range.last }
    raise MissingTNUoSDataForThisYear, "Missing years data for #{date}" if years.empty?
    years.values[0]
  end

  # TODO(PH, 23Jun2021) - calculate if possible or get user to enter from bill
  def transmission_line_loss_factor(_date, _tariff)
    1.08
  end

  def average_kw_on_triad_datetimes(date, amr_data)
    triads = TRIAD_DATETIMES[year(date)]
    kws = triads.map do |dt|
      d, hh_index = DateTimeHelper.date_and_half_hour_index(dt)
      amr_data.kw(d, hh_index)
    end
    kws.sum / 3.0
  end

  def year(date)
    year  = FINANCIAL_YEARS.select { |date_range| date >= date_range.first && date <= date_range.last }
    raise MissingTNUoSDataForThisYear, "Missing years data for #{date}" if year.empty?
    year
  end

  def tnuos_zone(mpan)
    region = DUOSCharges.region_number(mpan)
    TNUOS_ZONES_TO_MPAN_REGION_MAP.key(region)
  end
end
