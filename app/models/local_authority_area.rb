# == Schema Information
#
# Table name: local_authority_areas
#
#  id                          :bigint(8)        not null, primary key
#  code                        :string
#  mailchimp_fields_changed_at :datetime
#  name                        :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
class LocalAuthorityArea < ApplicationRecord
  include MailchimpUpdateable

  watch_mailchimp_fields :name

  validates_presence_of :code, :name
  validates_uniqueness_of :code

  has_many :schools
end
