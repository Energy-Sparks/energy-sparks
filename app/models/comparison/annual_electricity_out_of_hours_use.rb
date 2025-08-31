# == Schema Information
#
# Table name: comparison_annual_electricity_out_of_hours_uses
#
#  alert_generation_run_id                       :bigint(8)
#  community_gbp                                 :float
#  community_percent                             :float
#  electricity_economic_tariff_changed_this_year :boolean
#  holidays_percent                              :float
#  id                                            :bigint(8)
#  out_of_hours_gbp                              :float
#  potential_saving_gbp                          :float
#  school_id                                     :bigint(8)
#  schoolday_closed_percent                      :float
#  schoolday_open_percent                        :float
#  weekends_percent                              :float
#
# Indexes
#
#  idx_on_school_id_579efb1ff6  (school_id) UNIQUE
#
class Comparison::AnnualElectricityOutOfHoursUse < Comparison::View
  scope :with_data, -> { where.not(schoolday_open_percent: nil) }
  scope :sort_default, -> { order(schoolday_open_percent: :desc) }

  def self.default_headers
    [
      I18n.t('analytics.benchmarking.configuration.column_headings.school'),
      I18n.t('analytics.benchmarking.configuration.column_headings.school_day_open'),
      I18n.t('analytics.benchmarking.configuration.column_headings.school_day_closed'),
      I18n.t('analytics.benchmarking.configuration.column_headings.holiday'),
      I18n.t('analytics.benchmarking.configuration.column_headings.weekend'),
      I18n.t('analytics.benchmarking.configuration.column_headings.community'),
      I18n.t('analytics.benchmarking.configuration.column_headings.community_usage_cost'),
      I18n.t('analytics.benchmarking.configuration.column_headings.last_year_out_of_hours_cost'),
      I18n.t('analytics.benchmarking.configuration.column_headings.saving_if_improve_to_exemplar'),
    ]
  end
end
