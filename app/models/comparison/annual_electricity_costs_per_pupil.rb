# == Schema Information
#
# Table name: annual_electricity_costs_per_pupils
#
#  alert_generation_run_id                    :bigint(8)
#  id                                         :bigint(8)
#  last_year_gbp                              :float
#  one_year_electricity_per_pupil_gbp         :float
#  one_year_saving_versus_exemplar_gbpcurrent :float
#  school_id                                  :bigint(8)
#
class Comparison::AnnualElectricityCostsPerPupil < Comparison::View
  scope :with_data, -> { where.not(one_year_electricity_per_pupil_gbp: nil) }
  scope :sort_default, -> { order(one_year_electricity_per_pupil_gbp: :desc) }
end
