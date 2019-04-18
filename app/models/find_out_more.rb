# == Schema Information
#
# Table name: find_out_mores
#
#  alert_id                             :bigint(8)        not null
#  alert_type_rating_content_version_id :bigint(8)        not null
#  created_at                           :datetime         not null
#  find_out_more_calculation_id         :bigint(8)        not null
#  id                                   :bigint(8)        not null, primary key
#  updated_at                           :datetime         not null
#
# Indexes
#
#  fom_fom_content_v_id                                  (alert_type_rating_content_version_id)
#  index_find_out_mores_on_alert_id                      (alert_id)
#  index_find_out_mores_on_find_out_more_calculation_id  (find_out_more_calculation_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_rating_content_version_id => alert_type_rating_content_versions.id) ON DELETE => cascade
#  fk_rails_...  (find_out_more_calculation_id => find_out_more_calculations.id) ON DELETE => cascade
#

class FindOutMore < ApplicationRecord
  belongs_to :calculation, class_name: 'FindOutMoreCalculation', foreign_key: :find_out_more_calculation_id
  belongs_to :alert
  belongs_to :content_version, class_name: 'AlertTypeRatingContentVersion', foreign_key: :alert_type_rating_content_version_id

  def activity_types
    alert.alert_type.ordered_activity_types
  end
end
