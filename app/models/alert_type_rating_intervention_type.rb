# == Schema Information
#
# Table name: alert_type_rating_intervention_types
#
#  alert_type_rating_id :bigint(8)        not null
#  created_at           :datetime         not null
#  id                   :bigint(8)        not null, primary key
#  intervention_type_id :bigint(8)        not null
#  position             :integer
#  updated_at           :datetime         not null
#
# Indexes
#
#  idx_alert_type_rating_intervention_types_on_alrt_type_id  (alert_type_rating_id)
#  idx_alert_type_rating_intervention_types_on_int_type_id   (intervention_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_rating_id => alert_type_ratings.id)
#  fk_rails_...  (intervention_type_id => intervention_types.id)
#
class AlertTypeRatingInterventionType < ApplicationRecord
  belongs_to :intervention_type
  belongs_to :alert_type_rating
  validates :intervention_type, :alert_type_rating, presence: true
end
