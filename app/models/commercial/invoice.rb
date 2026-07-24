# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_invoices
#
#  id                    :bigint(8)        not null, primary key
#  purchase_order_number :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contract_id           :bigint(8)        not null
#  created_by_id         :bigint(8)        not null
#
# Indexes
#
#  index_commercial_invoices_on_contract_id    (contract_id)
#  index_commercial_invoices_on_created_by_id  (created_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (contract_id => commercial_contracts.id)
#  fk_rails_...  (created_by_id => users.id)
#
module Commercial
  class Invoice < ApplicationRecord
    include CsvExportable

    self.table_name = 'commercial_invoices'

    scope :by_date, -> { order(created_at: :asc) }

    belongs_to :contract, class_name: 'Commercial::Contract'
    belongs_to :created_by, class_name: 'User'

    has_many :line_items, class_name: 'Commercial::LineItem', dependent: :destroy
    has_many :licences, through: :line_items

    delegate :contract_holder, to: :contract
    accepts_nested_attributes_for :line_items

    def self.csv_headers
      ['ID', 'Contract', 'Contract Holder',
       'Created By', 'Date', 'Purchase Order Number',
       'Base Price', 'Metering Fee', 'Private Account Fee', 'Total']
    end

    def self.csv_attributes
      %w[invoice_number contract.name contract.contract_holder.name
         created_by.display_name date purchase_order_number
         value.base_price value.metering_fee value.private_account_fee value.total]
    end

    def date
      created_at.to_date
    end

    def invoice_number
      "ES#{id.to_s.rjust(4, '0')}"
    end

    def value
      @value ||= begin
        prices = line_items.map(&:value)
        Price.new(
          base_price: prices.sum(&:base_price),
          metering_fee: prices.sum(&:metering_fee),
          private_account_fee: prices.sum(&:private_account_fee)
        )
      end
    end
  end
end
