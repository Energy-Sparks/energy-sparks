# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_xero_account_codes
#
#  id         :bigint(8)        not null, primary key
#  code       :integer
#  label      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
      false if contracts.any?
    end

    def display_label
      "#{code} - #{label}"
    end
  end
end
