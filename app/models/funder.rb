# frozen_string_literal: true

# == Schema Information
#
# Table name: funders
#
#  id                          :bigint(8)        not null, primary key
#  invoiced                    :boolean          default(TRUE), not null
#  mailchimp_fields_changed_at :datetime
#  name                        :string           not null
#
class Funder < ApplicationRecord
  include MailchimpUpdateable
  include Commercial::ContractHolder

  watch_mailchimp_fields :name

  scope :by_name, -> { order(name: :asc) }

  validates :name, presence: true, uniqueness: true
end
