# frozen_string_literal: true

# == Schema Information
#
# Table name: comparison_electricity_peak_kw_per_pupils
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
# Indexes
#
#  index_comparison_electricity_peak_kw_per_pupils_on_school_id  (school_id) UNIQUE
#
module Comparison
  class ElectricityPeakKwPerPupil < Comparison::View
  end
end
