# == Schema Information
#
# Table name: sms_records
#
#  alert_subscription_event_id :bigint(8)
#  created_at                  :datetime         not null
#  id                          :bigint(8)        not null, primary key
#  mobile_phone_number         :text
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_sms_records_on_alert_subscription_event_id  (alert_subscription_event_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_subscription_event_id => alert_subscription_events.id) ON DELETE => cascade
#

class SmsRecord < ApplicationRecord
  belongs_to :alert_subscription_event
end
