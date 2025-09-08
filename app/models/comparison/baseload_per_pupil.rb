# == Schema Information
#
# Table name: comparison_baseload_per_pupils
#
#  alert_generation_run_id                       :bigint(8)
#  annual_baseload_percent                       :float
#  average_baseload_last_year_gbp                :float
#  average_baseload_last_year_kw                 :float
#  electricity_economic_tariff_changed_this_year :boolean
#  id                                            :bigint(8)
#  one_year_baseload_per_pupil_kw                :float
#  one_year_saving_versus_exemplar_gbp           :float
#  school_id                                     :bigint(8)
#
# Indexes
#
#  index_comparison_baseload_per_pupils_on_school_id  (school_id) UNIQUE
#
class Comparison::BaseloadPerPupil < Comparison::View
  def self.report_headers
    [
      I18n.t('analytics.benchmarking.configuration.column_headings.school'),
      I18n.t('analytics.benchmarking.configuration.column_headings.baseload_per_pupil_w'),
      I18n.t('analytics.benchmarking.configuration.column_headings.last_year_cost_of_baseload'),
      I18n.t('analytics.benchmarking.configuration.column_headings.average_baseload_kw'),
      I18n.t('analytics.benchmarking.configuration.column_headings.baseload_percent'),
      I18n.t('analytics.benchmarking.configuration.column_headings.saving_if_matched_exemplar_school')
    ]
  end
end
