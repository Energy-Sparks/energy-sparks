# frozen_string_literal: true

# == Schema Information
#
# Table name: electricity_peak_kw_per_pupils
#
#  alert_generation_run_id                        :bigint(8)
#  average_school_day_last_year_kw                :float
#  average_school_day_last_year_kw_per_floor_area :float
#  electricity_economic_tariff_changed_this_year  :boolean
#  exemplar_kw                                    :float
#  id                                             :bigint(8)
#  one_year_saving_versus_exemplar_gbp            :float
#  school_id                                      :bigint(8)
#
module Comparison
  class ChangeInElectricityConsumptionRecentSchoolWeeks < Comparison::View
  end
end
