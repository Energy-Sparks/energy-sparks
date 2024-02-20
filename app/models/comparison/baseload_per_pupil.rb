# == Schema Information
#
# Table name: baseload_per_pupils
#
#  alert_generation_run_id                       :bigint(8)
#  annual_baseload_percent                       :float
#  average_baseload_last_year_gbp                :float
#  average_baseload_last_year_kw                 :float
#  electricity_economic_tariff_changed_this_year :boolean
#  id                                            :bigint(8)        primary key
#  one_year_baseload_per_pupil_kw                :float
#  one_year_saving_versus_exemplar_gbp           :float
#  school_id                                     :bigint(8)
#
class Comparison::BaseloadPerPupil < ApplicationRecord
  belongs_to :school

  self.primary_key = :id

  def readonly?
    true
  end
end
