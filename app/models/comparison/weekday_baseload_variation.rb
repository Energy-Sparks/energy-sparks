# == Schema Information
#
# Table name: weekday_baseload_variations
#
#  alert_generation_run_id                       :bigint(8)
#  annual_cost_gbpcurrent                        :float
#  electricity_economic_tariff_changed_this_year :boolean
#  id                                            :bigint(8)
#  max_day_kw                                    :float
#  max_day_str                                   :float
#  min_day_kw                                    :float
#  min_day_str                                   :float
#  percent_intraday_variation                    :float
#  school_id                                     :bigint(8)
#
class Comparison::WeekdayBaseloadVariation < Comparison::View
end
