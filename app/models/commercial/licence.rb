# == Schema Information
#
# Table name: commercial_licences
#
#  contract_id       :bigint(8)        not null
#  created_at        :datetime         not null
#  created_by_id     :bigint(8)
#  end_date          :date             not null
#  id                :bigint(8)        not null, primary key
#  invoice_reference :string
#  school_id         :bigint(8)        not null
#  start_date        :date             not null
#  status            :enum             default("provisional"), not null
#  updated_at        :datetime         not null
#  updated_by_id     :bigint(8)
#
# Indexes
#
#  index_commercial_licences_on_contract_id    (contract_id)
#  index_commercial_licences_on_created_by_id  (created_by_id)
#  index_commercial_licences_on_school_id      (school_id)
#  index_commercial_licences_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (contract_id => commercial_contracts.id)
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (updated_by_id => users.id)
#
module Commercial
  class Licence < ApplicationRecord
    include Trackable
    include TemporalRange

    self.table_name = 'commercial_licences'

    belongs_to :contract, class_name: 'Commercial::Contract'
    belongs_to :school

    delegate :product, to: :contract

    LICENCE_STATUS = {
      provisional: 'provisional',
      confirmed: 'confirmed',
      pending_invoice: 'pending_invoice',
      invoiced: 'invoiced'
    }.freeze

    enum :status, LICENCE_STATUS
  end
end
