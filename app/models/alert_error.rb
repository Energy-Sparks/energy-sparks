# == Schema Information
#
# Table name: alert_errors
#
#  alert_generation_run_id :bigint(8)        not null
#  alert_type_id           :bigint(8)        not null
#  asof_date               :date             not null
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  information             :text
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_alert_errors_on_alert_generation_run_id  (alert_generation_run_id)
#  index_alert_errors_on_alert_type_id            (alert_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_generation_run_id => alert_generation_runs.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_id => alert_types.id) ON DELETE => cascade
#

class AlertError < ApplicationRecord
  belongs_to :alert_type
  belongs_to :alert_generation_run
  belongs_to :comparison_report, class_name: 'Comparison::Report', optional: true

  def alert_type_title_with_report
    alert_type.title + comparison_report.nil? ? '' : "#{comparison_report.title}}"
  end
end
