# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_contracts
#
#  agreed_school_price   :decimal(10, 2)
#  comments              :text
#  contract_holder_id    :bigint(8)        not null
#  contract_holder_type  :string           not null
#  created_at            :datetime         not null
#  created_by_id         :bigint(8)
#  end_date              :date             not null
#  id                    :bigint(8)        not null, primary key
#  invoice_terms         :enum             default("pro_rata"), not null
#  licence_period        :enum             default("contract"), not null
#  licence_years         :decimal(4, 2)
#  name                  :string           not null
#  number_of_schools     :integer          not null
#  product_id            :bigint(8)        not null
#  purchase_order_number :string
#  start_date            :date             not null
#  status                :enum             default("provisional"), not null
#  updated_at            :datetime         not null
#  updated_by_id         :bigint(8)
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
    include Deletable

    self.table_name = 'commercial_contracts'

    scope :by_name, -> { order(name: :asc) }

    belongs_to :product, class_name: 'Commercial::Product'
    belongs_to :contract_holder, polymorphic: true

    CONTRACT_STATUS = {
      provisional: 'provisional',
      confirmed: 'confirmed'
    }.freeze

    STATUS_COLOUR = {
      provisional: :warning,
      confirmed: :success
    }.freeze

    CONTRACT_LICENCE_PERIOD = {
      contract: 'contract',
      custom: 'custom'
    }.freeze

    CONTRACT_INVOICE_TERMS = {
      pro_rata: 'pro_rata',
      full: 'full'
    }.freeze

    enum :status, CONTRACT_STATUS
    enum :licence_period, CONTRACT_LICENCE_PERIOD
    enum :invoice_terms, CONTRACT_INVOICE_TERMS

    validates :name, :start_date, :end_date, presence: true

    validates :number_of_schools, numericality: { only_integer: true, greater_than: 0 }
    validates :licence_years, numericality: { greater_than: 0 }, if: :custom?
    validate :ensure_only_editable_attributes_changed, unless: :new_record?

    has_many :licences, class_name: 'Commercial::Licence', dependent: :destroy

    accepts_nested_attributes_for :licences, allow_destroy: true

    def self.as_renewal(original)
      new(
        original.slice(
          :agreed_school_price,
          :contract_holder_type,
          :contract_holder_id,
          :invoice_terms,
          :licence_period,
          :licence_years,
          :number_of_schools,
          :product
        ).merge(
          comments: "Renewed from #{original.name}",
          end_date: original.end_date.next_year,
          start_date: original.end_date + 1.day
        )
      )
    end

    def status_colour
      STATUS_COLOUR[status.to_sym]
    end

    def deletable?
      !licences.invoiced.exists?
    end

    def editable_attribute?(name)
      new_record? || editable_attributes.include?(name)
    end

    # Some fields of a contract cannot be changed once created, e.g. contract terms.
    # Some are safe to always be changed, e.g. name
    # Others cannot be changed once invoicing has started, e.g. agreed_school_price
    def editable_attributes
      fields = %i[comments name purchase_order_number number_of_schools updated_by_id]
      fields += [:status] if provisional?
      fields += %i[agreed_school_price start_date end_date] unless licences.invoiced.exists?
      fields
    end

    def cascade_updates_to_licences?
      licences.exists? && saved_changes.keys.intersect?(%w[start_date end_date status])
    end

    private

    def destroy_error_message
      'Cannot delete a contract with an invoiced licence'
    end

    def ensure_only_editable_attributes_changed
      allowed = editable_attributes.map(&:to_s)
      # status is editable if previous status was provisional
      allowed << 'status' if status_changed? && status_was.to_s == 'provisional'

      changed   = changes_to_save.keys
      forbidden = changed - allowed

      forbidden.each do |attr|
        errors.add(attr, 'cannot be changed once the contract is in its current state')
      end
    end
  end
end
