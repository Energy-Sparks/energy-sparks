# == Schema Information
#
# Table name: find_out_mores
#
#  alert_id                             :bigint(8)        not null
#  alert_type_rating_content_version_id :bigint(8)        not null
#  content_generation_run_id            :bigint(8)        not null
#  created_at                           :datetime         not null
#  id                                   :bigint(8)        not null, primary key
#  updated_at                           :datetime         not null
#
# Indexes
#
#  fom_fom_content_v_id                               (alert_type_rating_content_version_id)
#  index_find_out_mores_on_alert_id                   (alert_id)
#  index_find_out_mores_on_content_generation_run_id  (content_generation_run_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_rating_content_version_id => alert_type_rating_content_versions.id) ON DELETE => cascade
#  fk_rails_...  (content_generation_run_id => content_generation_runs.id) ON DELETE => cascade
#

class FindOutMore < ApplicationRecord
  belongs_to :content_generation_run
  belongs_to :alert
  belongs_to :content_version, class_name: 'AlertTypeRatingContentVersion', foreign_key: :alert_type_rating_content_version_id

  def activity_types
    content_version.alert_type_rating.ordered_activity_types
  end

  def intervention_types
    content_version.alert_type_rating.ordered_intervention_types
  end
end
