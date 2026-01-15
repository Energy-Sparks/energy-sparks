# == Schema Information
#
# Table name: commercial_contracts
#
#  agreed_school_price  :float
#  comments             :text
#  contract_holder_id   :bigint(8)        not null
#  contract_holder_type :string           not null
#  created_at           :datetime         not null
#  created_by_id        :bigint(8)
#  end_date             :date             not null
#  id                   :bigint(8)        not null, primary key
#  invoice_terms        :enum             default("pro_rata"), not null
#  licence_period       :enum             default("contract"), not null
#  name                 :string           not null
#  number_of_schools    :integer          not null
#  product_id           :bigint(8)        not null
#  start_date           :date             not null
#  status               :enum             default("provisional"), not null
#  updated_at           :datetime         not null
#  updated_by_id        :bigint(8)
#
# Indexes
#
#  index_commercial_contracts_on_contract_holder  (contract_holder_type,contract_holder_id)
#  index_commercial_contracts_on_created_by_id    (created_by_id)
#  index_commercial_contracts_on_name             (name) UNIQUE
#  index_commercial_contracts_on_product_id       (product_id)
#  index_commercial_contracts_on_updated_by_id    (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (product_id => commercial_products.id)
#  fk_rails_...  (updated_by_id => users.id)
#
module Commercial
  class Contract < ApplicationRecord
    include Trackable
    include TemporalRange
    include HasContractHolder

    self.table_name = 'commercial_contracts'

    belongs_to :product, class_name: 'Commercial::Product'
    belongs_to :contract_holder, polymorphic: true

    CONTRACT_STATUS = {
      provisional: 'provisional',
      confirmed: 'confirmed',
    }.freeze

    CONTRACT_LICENCE_PERIOD = {
      contract: 'contract',
      one_year: 'one_year',
    }.freeze

    CONTRACT_INVOICE_TERMS = {
      pro_rata: 'pro_rata',
      full: 'full',
    }.freeze

    enum :status, CONTRACT_STATUS
    enum :licence_period, CONTRACT_LICENCE_PERIOD
    enum :invoice_terms, CONTRACT_INVOICE_TERMS

    validates_presence_of :name, :start_date, :end_date

    validates :number_of_schools, numericality: { only_integer: true, greater_than: 0 }
  end
end
