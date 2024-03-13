# == Schema Information
#
# Table name: recent_change_in_baseloads
#
#  alert_generation_run_id                       :bigint(8)
#  average_baseload_last_week_kw                 :float
#  average_baseload_last_year_kw                 :float
#  change_in_baseload_kw                         :float
#  electricity_economic_tariff_changed_this_year :boolean
#  id                                            :bigint(8)
#  next_year_change_in_baseload_gbpcurrent       :float
#  predicted_percent_increase_in_usage           :float
#  school_id                                     :bigint(8)
#
class Comparison::RecentChangeInBaseload < Comparison::View
  scope :with_data, -> { where.not(predicted_percent_increase_in_usage: nil) }
  scope :sort_default, -> { order(predicted_percent_increase_in_usage: :desc) }
end
