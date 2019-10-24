# == Schema Information
#
# Table name: analysis_pages
#
#  alert_id                             :bigint(8)
#  alert_type_rating_content_version_id :bigint(8)
#  category                             :integer
#  content_generation_run_id            :bigint(8)
#  created_at                           :datetime         not null
#  id                                   :bigint(8)        not null, primary key
#  priority                             :decimal(, )      default(0.0)
#  updated_at                           :datetime         not null
#
# Indexes
#
#  index_analysis_pages_on_alert_id                              (alert_id)
#  index_analysis_pages_on_alert_type_rating_content_version_id  (alert_type_rating_content_version_id)
#  index_analysis_pages_on_content_generation_run_id             (content_generation_run_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id) ON DELETE => restrict
#  fk_rails_...  (alert_type_rating_content_version_id => alert_type_rating_content_versions.id) ON DELETE => restrict
#  fk_rails_...  (content_generation_run_id => content_generation_runs.id) ON DELETE => cascade
#

class AnalysisPage < ApplicationRecord
  belongs_to :content_generation_run
  belongs_to :alert
  belongs_to :content_version, class_name: 'AlertTypeRatingContentVersion', foreign_key: :alert_type_rating_content_version_id

  enum category: AlertType::SUB_CATEGORIES

  scope :by_priority, -> { order(priority: :desc) }
end
