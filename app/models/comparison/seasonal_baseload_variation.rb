# == Schema Information
#
# Table name: comparison_seasonal_baseload_variations
#
#  id                                            :bigint
#  annual_cost_gbpcurrent                        :float
#  electricity_economic_tariff_changed_this_year :boolean
#  percent_seasonal_variation                    :float
#  summer_kw                                     :float
#  winter_kw                                     :float
#  alert_generation_run_id                       :bigint
#  school_id                                     :bigint
#
# Indexes
#
#  index_comparison_seasonal_baseload_variations_on_school_id  (school_id) UNIQUE
#
class Comparison::SeasonalBaseloadVariation < Comparison::View
end
