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
  include ContractHolder

  watch_mailchimp_fields :name

  has_many :schools
  has_many :school_onboardings

  scope :with_schools,  -> { where.associated(:schools) }
  scope :by_name,       -> { order(name: :asc) }

  validates :name, presence: true, uniqueness: true

  # Return counts of visible schools by funder
  # includes funders without any funded schools, but not schools without any source of funding. See Schools.unfunded.
  def self.funded_school_counts(visible: true, data_enabled: true)
    Funder.joins('LEFT JOIN schools ON funders.id = schools.funder_id ' \
                 "AND #{ActiveRecord::Base.sanitize_sql_for_conditions(
                   ['schools.visible = ? AND schools.data_enabled = ?', visible, data_enabled]
                 )}")
          .group(:name).count('schools.id')
  end

  before_destroy :prevent_destroy_if_contracts_exist

  private

  def prevent_destroy_if_contracts_exist
    return unless contracts.exists?
    errors.add(:base, 'Cannot delete a funder with contracts')
    throw(:abort)
  end
end
