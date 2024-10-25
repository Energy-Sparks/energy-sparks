# == Schema Information
#
# Table name: alert_type_rating_unsubscriptions
#
#  alert_subscription_event_id :bigint(8)
#  alert_type_rating_id        :bigint(8)        not null
#  contact_id                  :bigint(8)        not null
#  created_at                  :datetime         not null
#  effective_until             :date
#  id                          :bigint(8)        not null, primary key
#  reason                      :text
#  scope                       :integer          not null
#  unsubscription_period       :integer          not null
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
  belongs_to :alert_subscription_event, optional: true

  enum :scope, { email: 0, sms: 1 }
  enum :unsubscription_period, { one_month: 0, six_months: 1, forever: 2 }

  scope :active, ->(today) { where('effective_until IS NULL OR effective_until < ?', today) }

  validates :alert_type_rating, :reason, :unsubscription_period, presence: true

  def self.generate(scope:, event:, reason:, unsubscription_period:)
    effective_until = case unsubscription_period
                      when :one_month, 'one_month' then 1.month.from_now
                      when :six_months, 'six_months' then 6.months.from_now
                      end
    new(
      alert_subscription_event: event,
      contact: event.contact,
      alert_type_rating: event.content_version.alert_type_rating,
      unsubscription_period:,
      effective_until:,
      scope:,
      reason:
    )
  end
end
