# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_xero_account_codes
#
#  id         :bigint(8)        not null, primary key
#  code       :integer          not null
#  label      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_commercial_xero_account_codes_on_code  (code) UNIQUE
#
module Commercial
  class XeroAccountCode < ApplicationRecord
    include Deletable

    self.table_name = 'commercial_xero_account_codes'

    validates :code, presence: true, uniqueness: true
    validates :label, presence: true

    scope :by_code, -> { order(:code) }

    has_many :contracts, class_name: 'Commercial::Contract', dependent: :restrict_with_error

    def deletable?
      return false if contracts.any?

      true
    end

    def display_label
      "#{code} - #{label}"
    end
  end
end
