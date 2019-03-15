# == Schema Information
#
# Table name: alert_subscription_events
#
#  alert_id              :bigint(8)
#  alert_subscription_id :bigint(8)
#  communication_type    :integer          default("email"), not null
#  contact_id            :bigint(8)
#  created_at            :datetime         not null
#  id                    :bigint(8)        not null, primary key
#  message               :text
#  status                :integer          default("pending"), not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_alert_subscription_events_on_alert_id               (alert_id)
#  index_alert_subscription_events_on_alert_subscription_id  (alert_subscription_id)
#  index_alert_subscription_events_on_contact_id             (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_id => alerts.id)
#  fk_rails_...  (alert_subscription_id => alert_subscriptions.id)
#  fk_rails_...  (contact_id => contacts.id)
#

class AlertSubscriptionEvent < ApplicationRecord
  belongs_to :alert_subscription, inverse_of: :alert_subscription_events
  belongs_to :contact,            inverse_of: :alert_subscription_events
  belongs_to :alert

  enum status: [:pending, :sent]
  enum communication_type: [:email, :sms]
end
