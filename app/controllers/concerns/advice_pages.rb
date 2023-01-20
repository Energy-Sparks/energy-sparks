module AdvicePages
  extend ActiveSupport::Concern

  def variation_rating(variation_percentage)
    calculate_rating_from_range(0, 0.50, variation_percentage.abs)
  end

  # from analytics: lib/dashboard/charting_and_reports/content_base.rb
  def calculate_rating_from_range(good_value, bad_value, actual_value)
    [10.0 * [(actual_value - bad_value) / (good_value - bad_value), 0.0].max, 10.0].min.round(1)
  end

  def build_meter_breakdown(mpan_mprn, breakdown, previous_year_baseload)
    OpenStruct.new(
      baseload_kw: breakdown.baseload_kw(mpan_mprn),
      baseload_cost_£: breakdown.baseload_cost_£(mpan_mprn),
      percentage_baseload: breakdown.percentage_baseload(mpan_mprn),
      baseload_previous_year_kw: previous_year_baseload
    )
  end

  def build_meter_breakdown_totals(breakdowns, previous_year_baseload)
    OpenStruct.new(
      baseload_kw: breakdowns.values.map(&:baseload_kw).sum,
      baseload_cost_£: breakdowns.values.map(&:baseload_cost_£).sum,
      percentage_baseload: breakdowns.values.map(&:percentage_baseload).sum,
      baseload_previous_year_kw: previous_year_baseload
    )
  end

  def build_seasonal_variation(variation, saving)
    OpenStruct.new(
      winter_kw: variation.winter_kw,
      summer_kw: variation.summer_kw,
      percentage: variation.percentage,
      estimated_saving_£: saving.£,
      estimated_saving_co2: saving.co2,
      variation_rating: variation_rating(variation.percentage)
    )
  end

  def build_intraweek_variation(variation, saving)
    OpenStruct.new(
      max_day_kw: variation.max_day_kw,
      min_day_kw: variation.min_day_kw,
      percent_intraday_variation: variation.percent_intraday_variation,
      estimated_saving_£: saving.£,
      estimated_saving_co2: saving.co2,
      variation_rating: variation_rating(variation.percent_intraday_variation)
    )
  end
end
