# == Schema Information
#
# Table name: contacts
#
#  description         :text
#  email_address       :text
#  id                  :bigint(8)        not null, primary key
#  mobile_phone_number :text
#  name                :text
#  school_id           :bigint(8)
#
# Indexes
#
#  index_contacts_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class Contact < ApplicationRecord
  belongs_to :school, inverse_of: :contacts
  has_many   :alert_subscription_events
  has_many   :alert_type_rating_unsubscriptions

  validates :mobile_phone_number, presence: true, unless: ->(contact) { contact.email_address.present? }
  validates :email_address,       presence: true, unless: ->(contact) { contact.mobile_phone_number.present? }
  validates :description,         presence: true, unless: ->(contact) { contact.name.present? }
  validates :name,                presence: true, unless: ->(contact) { contact.description.present? }

  def display_name
    "#{name} #{description}"
  end
end
