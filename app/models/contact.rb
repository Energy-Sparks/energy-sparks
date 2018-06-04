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
  has_and_belongs_to_many :alerts
  belongs_to :school, inverse_of: :contacts
end
