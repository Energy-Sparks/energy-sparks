module HasContractHolder
  extend ActiveSupport::Concern

  included do
    validate :validate_contract_holder_type
  end

  private

  ALLOWED_HOLDERS = [School, SchoolGroup, Funder].freeze

  def validate_contract_holder_type
    return if contract_holder && ALLOWED_HOLDERS.include?(contract_holder.class)
    errors.add(:contract_holder, 'must be a School, SchoolGroup, or Funder')
  end
end
