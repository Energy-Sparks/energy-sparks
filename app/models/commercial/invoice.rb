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
    self.table_name = 'commercial_invoices'

    scope :by_date, -> { order(created_at: :asc) }

    belongs_to :contract, class_name: 'Commercial::Contract'
    belongs_to :created_by, class_name: 'User'

    has_many :line_items, class_name: 'Commercial::LineItem', dependent: :destroy

    delegate :contract_holder, to: :contract

    def invoice_number
      "ES#{id.to_s.rjust(4, '0')}"
    end
  end
end
