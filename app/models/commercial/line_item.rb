# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_line_items
#
#  id                  :bigint(8)        not null, primary key
#  base_price          :decimal(10, 2)   not null
#  metering_fee        :decimal(10, 2)   not null
#  number_of_meters    :integer          default(0), not null
#  private_account     :boolean          default(FALSE), not null
#  private_account_fee :decimal(10, 2)   not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  invoice_id          :bigint(8)        not null
#  licence_id          :bigint(8)        not null
#
# Indexes
#
#  index_commercial_line_items_on_invoice_id  (invoice_id)
#  index_commercial_line_items_on_licence_id  (licence_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => commercial_invoices.id)
#  fk_rails_...  (licence_id => commercial_licences.id)
#
module Commercial
  class LineItem < ApplicationRecord
    self.table_name = 'commercial_line_items'

    belongs_to :invoice, class_name: 'Commercial::Invoice'
    belongs_to :licence, class_name: 'Commercial::Licence'

    validates :base_price, :metering_fee, :private_account_fee, presence: true

    delegate :school, to: :licence

    def value
      Price.new(base_price:, metering_fee:, private_account_fee:)
    end
  end
end
