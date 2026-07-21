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
    include CsvExportable

    self.table_name = 'commercial_line_items'

    belongs_to :invoice, class_name: 'Commercial::Invoice'
    belongs_to :licence, class_name: 'Commercial::Licence'

    validates :base_price, :metering_fee, :private_account_fee, presence: true

    delegate :school, to: :licence

    scope :with_context, -> { includes(:invoice, :licence) }
    scope :invoice_order, -> { order(invoice_id: :asc, id: :asc) }

    def self.csv_headers
      ['ID', 'Contract', 'Contract Holder',
       'Created By', 'Date', 'Purchase Order Number',
       'School', 'Licence Id', 'Licence Start Date', 'Licence End Date',
       'Private Account', 'Number of Meters',
       'Base Price', 'Metering Fee', 'Private Account Fee', 'Total']
    end

    def self.csv_attributes
      %w[invoice.invoice_number invoice.contract.name invoice.contract_holder.name
         invoice.created_by.display_name invoice.date invoice.purchase_order_number
         school.name licence.id licence.start_date licence.end_date
         private_account number_of_meters
         base_price metering_fee private_account_fee value.total]
    end

    def value
      Price.new(base_price:, metering_fee:, private_account_fee:)
    end
  end
end
