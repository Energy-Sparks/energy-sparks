# == Schema Information
#
# Table name: alert_type_rating_unsubscriptions
#
#  alert_subscription_event_id :bigint(8)        not null
#  alert_type_rating_id        :bigint(8)        not null
#  contact_id                  :bigint(8)        not null
#  created_at                  :datetime         not null
#  effective_until             :date
#  id                          :bigint(8)        not null, primary key
#  reason                      :text
#  scope                       :integer          not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  altunsub_event                                                   (alert_subscription_event_id)
#  index_alert_type_rating_unsubscriptions_on_alert_type_rating_id  (alert_type_rating_id)
#  index_alert_type_rating_unsubscriptions_on_contact_id            (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_subscription_event_id => alert_subscription_events.id) ON DELETE => cascade
#  fk_rails_...  (alert_type_rating_id => alert_type_ratings.id) ON DELETE => cascade
#  fk_rails_...  (contact_id => contacts.id) ON DELETE => cascade
#

class AlertTypeRatingUnsubscription < ApplicationRecord
  belongs_to :alert_type_rating
  belongs_to :contact
  belongs_to :alert_subscription_event

  enum scope: [:email, :sms]

  scope :active, ->(today) { where('effective_until IS NULL OR effective_until < ?', today)}


  validates :alert_type_rating, presence: true
end
