# frozen_string_literal: true

# == Schema Information
#
# Table name: baseload_per_pupils
#
#  alert_generation_run_id                        :bigint(8)
#  average_school_day_last_year_kw                :float
#  average_school_day_last_year_kw_per_floor_area :float
#  exemplar_kw                                    :float
#  id                                             :bigint(8)
#  saving_if_match_exemplar_gbp                   :float
#  school_id                                      :bigint(8)
#
module Comparison
  class ElectricityPeakKwPerPupil < Comparison::View
  end
end
