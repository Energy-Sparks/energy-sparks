# == Schema Information
#
# Table name: comparison_weekday_baseload_variations
#
#  alert_generation_run_id                       :bigint(8)
#  annual_cost_gbpcurrent                        :float
#  electricity_economic_tariff_changed_this_year :boolean
#  id                                            :bigint(8)
#  max_day                                       :integer
#  max_day_kw                                    :float
#  min_day                                       :integer
#  min_day_kw                                    :float
#  percent_intraday_variation                    :float
#  school_id                                     :bigint(8)
#
# Indexes
#
#  index_comparison_weekday_baseload_variations_on_school_id  (school_id) UNIQUE
#
class Comparison::WeekdayBaseloadVariation < Comparison::View
end
