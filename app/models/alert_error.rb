# == Schema Information
#
# Table name: alert_errors
#
#  id                      :bigint           not null, primary key
#  asof_date               :date             not null
#  information             :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  alert_generation_run_id :bigint           not null
#  alert_type_id           :bigint           not null
#  comparison_report_id    :bigint
#
# Indexes
#
#  index_alert_errors_on_alert_generation_run_id  (alert_generation_run_id)
#  index_alert_errors_on_alert_type_id            (alert_type_id)
#  index_alert_errors_on_comparison_report_id     (comparison_report_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_generation_run_id => alert_generation_runs.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_id => alert_types.id) ON DELETE => cascade
#  fk_rails_...  (comparison_report_id => comparison_reports.id)
#

class AlertError < ApplicationRecord
  include AlertTypeWithComparisonReport

  belongs_to :alert_type
  belongs_to :alert_generation_run
  belongs_to :comparison_report, class_name: 'Comparison::Report', optional: true
end
