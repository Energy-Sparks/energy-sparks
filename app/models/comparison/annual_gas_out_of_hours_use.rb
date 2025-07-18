# == Schema Information
#
# Table name: comparison_annual_gas_out_of_hours_uses
#
#  alert_generation_run_id               :bigint(8)
#  community_gbp                         :float
#  community_percent                     :float
#  gas_economic_tariff_changed_this_year :boolean
#  holidays_percent                      :float
#  id                                    :bigint(8)
#  out_of_hours_gbp                      :float
#  potential_saving_gbp                  :float
#  school_id                             :bigint(8)
#  schoolday_closed_percent              :float
#  schoolday_open_percent                :float
#  weekends_percent                      :float
#
# Indexes
#
#  index_comparison_annual_gas_out_of_hours_uses_on_school_id  (school_id) UNIQUE
#
class Comparison::AnnualGasOutOfHoursUse < Comparison::View
  scope :with_data, -> { where.not(schoolday_open_percent: nil) }
  scope :sort_default, -> { order(schoolday_open_percent: :desc) }
end
