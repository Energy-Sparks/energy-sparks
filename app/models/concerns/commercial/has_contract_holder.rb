# frozen_string_literal: true

module Commercial
  module HasContractHolder
    extend ActiveSupport::Concern

    ALLOWED_HOLDERS = [School, SchoolGroup, Funder].freeze

    included do
      validate :validate_contract_holder_type
    end

    private

    def validate_contract_holder_type
      return if contract_holder && ALLOWED_HOLDERS.include?(contract_holder.class)

      errors.add(:contract_holder, 'must be a School, SchoolGroup, or Funder')
    end
  end
end
