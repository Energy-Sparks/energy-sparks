# == Schema Information
#
# Table name: contacts
#
#  description         :text
#  email_address       :text
#  id                  :bigint(8)        not null, primary key
#  mobile_phone_number :text
#  name                :text
#  school_id           :bigint(8)        not null
#  staff_role_id       :bigint(8)
#  user_id             :bigint(8)
#
# Indexes
#
#  index_contacts_on_school_id      (school_id)
#  index_contacts_on_staff_role_id  (staff_role_id)
#  index_contacts_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (staff_role_id => staff_roles.id) ON DELETE => restrict
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
class Contact < ApplicationRecord
  belongs_to :school, inverse_of: :contacts
  belongs_to :user, optional: true
  belongs_to :staff_role, optional: true
  has_many   :alert_subscription_events
  has_many   :alert_type_rating_unsubscriptions

  scope :for_school, ->(school) { where(school: school) }

  validates :mobile_phone_number, presence: true, unless: ->(contact) { contact.email_address.present? }
  validates :email_address,       presence: true, unless: ->(contact) { contact.mobile_phone_number.present? }
  validates :name,                presence: true

  validates_uniqueness_of :email_address, scope: :school_id, unless: ->(contact) { contact.email_address.blank? }
  validates_uniqueness_of :mobile_phone_number, scope: :school_id, unless: ->(contact) { contact.mobile_phone_number.blank? }

  accepts_nested_attributes_for :user

  after_commit :update_user_mailchimp_timestamp, on: [:create, :destroy]

  def display_name
    name
  end

  def populate_from_user(user)
    self.user = user
    self.name = user.display_name
    self.email_address = user.email
    self.staff_role = user.staff_role
  end

  def preferred_locale
    user ? user.preferred_locale : :en
  end

  private

  def update_user_mailchimp_timestamp
    user&.touch_mailchimp_timestamp!
  end
end
