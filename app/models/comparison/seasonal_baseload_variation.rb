# == Schema Information
#
# Table name: comparison_seasonal_baseload_variations
#
#  alert_generation_run_id                       :bigint(8)
#  annual_cost_gbpcurrent                        :float
#  electricity_economic_tariff_changed_this_year :boolean
#  id                                            :bigint(8)
#  percent_seasonal_variation                    :float
#  school_id                                     :bigint(8)
#  summer_kw                                     :float
#  winter_kw                                     :float
#
# Indexes
#
#  index_comparison_seasonal_baseload_variations_on_school_id  (school_id) UNIQUE
#
class Comparison::SeasonalBaseloadVariation < Comparison::View
end
