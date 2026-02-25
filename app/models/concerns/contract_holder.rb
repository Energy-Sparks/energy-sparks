module ContractHolder
  extend ActiveSupport::Concern

  included do
    has_many :contracts, as: :contract_holder, class_name: 'Commercial::Contract'
    has_many :contract_contacts, as: :contract_holder, class_name: 'Commercial::ContractContact'
    has_many :default_contracted_schools, as: :default_contract_holder
  end
end
