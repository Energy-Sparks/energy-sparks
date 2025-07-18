# == Schema Information
#
# Table name: dashboard_alerts
#
#  alert_id                             :bigint(8)        not null
#  alert_type_rating_content_version_id :bigint(8)        not null
#  content_generation_run_id            :bigint(8)        not null
#  created_at                           :datetime         not null
#  dashboard                            :integer          not null
#  find_out_more_id                     :bigint(8)
#  id                                   :bigint(8)        not null, primary key
#  priority                             :decimal(, )      default(0.0), not null
#  updated_at                           :datetime         not null
#
# Indexes
#
#  index_dashboard_alerts_on_alert_id                              (alert_id)
#  index_dashboard_alerts_on_alert_type_rating_content_version_id  (alert_type_rating_content_version_id)
#  index_dashboard_alerts_on_content_generation_run_id             (content_generation_run_id)
#  index_dashboard_alerts_on_find_out_more_id                      (find_out_more_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_rating_content_version_id => alert_type_rating_content_versions.id) ON DELETE => restrict
#  fk_rails_...  (content_generation_run_id => content_generation_runs.id) ON DELETE => cascade
#  fk_rails_...  (find_out_more_id => find_out_mores.id) ON DELETE => nullify
#

class DashboardAlert < ApplicationRecord
  belongs_to :content_generation_run
  belongs_to :alert
  belongs_to :find_out_more, optional: true
  belongs_to :content_version, class_name: 'AlertTypeRatingContentVersion',
                               foreign_key: :alert_type_rating_content_version_id

  enum :dashboard, { teacher: 0, pupil: 1, public: 2, management: 3 }, suffix: :dashboard

  validates :priority, numericality: true

  scope :by_priority, -> { order(priority: :desc) }
end
