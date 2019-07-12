# == Schema Information
#
# Table name: alert_type_rating_activity_types
#
#  activity_type_id     :bigint(8)        not null
#  alert_type_rating_id :bigint(8)        not null
#  id                   :bigint(8)        not null, primary key
#  position             :integer          default(0), not null
#
# Indexes
#
#  index_alert_type_rating_activity_types_on_alert_type_rating_id  (alert_type_rating_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_rating_id => alert_type_ratings.id) ON DELETE => cascade
#

class AlertTypeRatingActivityType < ApplicationRecord
  belongs_to :activity_type
  belongs_to :alert_type_rating

  validates :activity_type, :alert_type_rating, presence: true
end
