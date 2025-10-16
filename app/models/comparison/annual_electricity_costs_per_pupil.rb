# == Schema Information
#
# Table name: comparison_annual_electricity_costs_per_pupils
#
#  alert_generation_run_id                    :bigint(8)
#  id                                         :bigint(8)
#  last_year_co2                              :float
#  last_year_gbp                              :float
#  last_year_kwh                              :float
#  one_year_electricity_per_pupil_co2         :float
#  one_year_electricity_per_pupil_gbp         :float
#  one_year_electricity_per_pupil_kwh         :float
#  one_year_saving_versus_exemplar_gbpcurrent :float
#  school_id                                  :bigint(8)
#
# Indexes
#
#  idx_on_school_id_1d369f6529  (school_id) UNIQUE
#
class Comparison::AnnualElectricityCostsPerPupil < Comparison::View
  scope :with_data, -> { where.not(one_year_electricity_per_pupil_gbp: nil) }
  scope :sort_default, -> { order(one_year_electricity_per_pupil_gbp: :desc) }
end
