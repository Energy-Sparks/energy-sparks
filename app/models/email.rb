# == Schema Information
#
# Table name: emails
#
#  id         :bigint           not null, primary key
#  sent_at    :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  contact_id :bigint           not null
#
# Indexes
#
#  index_emails_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id) ON DELETE => cascade
#

class Email < ApplicationRecord
  belongs_to :contact
  has_many   :alert_subscription_events
  has_many   :alerts, through: :alert_subscription_events

  def sent?
    ! sent_at.nil?
  end
end
