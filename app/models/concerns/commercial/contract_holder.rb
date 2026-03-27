# frozen_string_literal: true

module Commercial
  module ContractHolder
    extend ActiveSupport::Concern

    included do
      has_many :contracts,
               as: :contract_holder,
               class_name: 'Commercial::Contract',
               dependent: :restrict_with_exception

      has_many :contract_contacts,
               as: :contract_holder,
               class_name: 'Commercial::ContractContact',
               dependent: :restrict_with_exception

      has_many :default_contracted_schools,
               as: :default_contract_holder,
               class_name: 'School',
               dependent: :nullify
    end
  end
end
