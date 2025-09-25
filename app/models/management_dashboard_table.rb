# == Schema Information
#
# Table name: management_dashboard_tables
#
#  alert_id                             :bigint(8)
#  alert_type_rating_content_version_id :bigint(8)
#  content_generation_run_id            :bigint(8)
#  created_at                           :datetime         not null
#  id                                   :bigint(8)        not null, primary key
#  updated_at                           :datetime         not null
#
# Indexes
#
#  index_management_dashboard_tables_on_alert_id                   (alert_id)
#  index_management_dashboard_tables_on_content_generation_run_id  (content_generation_run_id)
#  man_dash_alert_content_version_index                            (alert_type_rating_content_version_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_rating_content_version_id => alert_type_rating_content_versions.id) ON DELETE => restrict
#  fk_rails_...  (content_generation_run_id => content_generation_runs.id) ON DELETE => cascade
#

class ManagementDashboardTable < ApplicationRecord
  belongs_to :content_generation_run
  belongs_to :alert
  belongs_to :content_version, class_name: 'AlertTypeRatingContentVersion', foreign_key: :alert_type_rating_content_version_id

  def data
    # analytics currently returns a hash serialised as string,
    # would be preferable to return e.g. json
    if alert.template_data['summary_data'].blank?
      summary_data = {}
    else
      # rubocop:disable Security/Eval
      summary_data = eval(alert.template_data['summary_data'])
      # rubocop:enable Security/Eval
    end
    Tables::SummaryTableData.new(summary_data)
  end
end
