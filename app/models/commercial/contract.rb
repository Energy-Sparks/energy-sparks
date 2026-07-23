# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_contracts
#
#  id                    :bigint(8)        not null, primary key
#  agreed_school_price   :decimal(10, 2)
#  comments              :text
#  contract_holder_type  :string           not null
#  end_date              :date             not null
#  invoice_terms         :enum             default("pro_rata"), not null
#  licence_period        :enum             default("contract"), not null
#  licence_years         :decimal(4, 2)
#  name                  :string           not null
#  number_of_schools     :integer          not null
#  purchase_order_number :string
#  start_date            :date             not null
#  status                :enum             default("provisional"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contract_holder_id    :bigint(8)        not null
#  created_by_id         :bigint(8)
#  product_id            :bigint(8)        not null
#  updated_by_id         :bigint(8)
#  xero_account_code_id  :bigint(8)
#
# Indexes
#
#  index_commercial_contracts_on_contract_holder       (contract_holder_type,contract_holder_id)
#  index_commercial_contracts_on_created_by_id         (created_by_id)
#  index_commercial_contracts_on_name                  (name) UNIQUE
#  index_commercial_contracts_on_product_id            (product_id)
#  index_commercial_contracts_on_updated_by_id         (updated_by_id)
#  index_commercial_contracts_on_xero_account_code_id  (xero_account_code_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (product_id => commercial_products.id)
#  fk_rails_...  (updated_by_id => users.id)
#  fk_rails_...  (xero_account_code_id => commercial_xero_account_codes.id)
#
module Commercial
  class Contract < ApplicationRecord # rubocop:disable Metrics/ClassLength
    include Trackable
    include TemporalRange
    include Commercial::HasContractHolder
    include Deletable

    self.table_name = 'commercial_contracts'

    scope :by_name, -> { order(name: :asc) }

    scope :over_licensed, lambda {
      joins(:licences)
        .group('commercial_contracts.id')
        .having('COUNT(commercial_licences.id) > commercial_contracts.number_of_schools')
    }

    scope :with_invoiced_contract_holders, lambda {
      joins('LEFT JOIN funders ON funders.id = commercial_contracts.contract_holder_id AND ' \
            "commercial_contracts.contract_holder_type = 'Funder'")
        .where("commercial_contracts.contract_holder_type != 'Funder' OR funders.invoiced = TRUE")
    }

    scope :pending_invoicing, lambda {
      with_invoiced_contract_holders.joins(:licences)
                                    .where(licences: { status: :pending_invoice })
                                    .distinct
    }

    belongs_to :product, class_name: 'Commercial::Product'
    belongs_to :contract_holder, polymorphic: true
    belongs_to :xero_account_code, optional: true, class_name: 'Commercial::XeroAccountCode'

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

    validates :start_date, :end_date, presence: true
    validates :name, presence: true, uniqueness: true

    validates :number_of_schools, numericality: { only_integer: true, greater_than: 0 }
    validates :licence_years, numericality: { greater_than: 0 }, if: :custom?
    validate :ensure_only_editable_attributes_changed, unless: :new_record?
    validate :validate_invoice_terms

    has_many :licences, class_name: 'Commercial::Licence', dependent: :destroy
    has_many :schools, -> { distinct }, through: :licences
    has_many :school_onboardings, dependent: :nullify
    has_many :invoices, class_name: 'Commercial::Invoice', dependent: :restrict_with_error

    accepts_nested_attributes_for :licences, allow_destroy: true

    attr_accessor :update_licences

    def update_licences?
      ActiveModel::Type::Boolean.new.cast(update_licences)
    end

    def self.contract_holder_name_sql
      <<~SQL.squish
        COALESCE(
          schools.name,
          school_groups.name,
          funders.name
        )
      SQL
    end

    def self.contract_holder_joins
      <<~SQL.squish
        LEFT JOIN schools
          ON schools.id = commercial_contracts.contract_holder_id
         AND commercial_contracts.contract_holder_type = 'School'
        LEFT JOIN school_groups
          ON school_groups.id = commercial_contracts.contract_holder_id
         AND commercial_contracts.contract_holder_type = 'SchoolGroup'
        LEFT JOIN funders
          ON funders.id = commercial_contracts.contract_holder_id
         AND commercial_contracts.contract_holder_type = 'Funder'
      SQL
    end

    scope :ordered_by_contract_holder_name, lambda {
      name_sql = contract_holder_name_sql

      joins(contract_holder_joins)
        .select(
          Arel.sql("commercial_contracts.*, #{name_sql} AS contract_holder_name")
        )
        .order(Arel.sql('contract_holder_name ASC'))
    }

    def self.count_case(expr, alias_name, id: 'licence_schools.id')
      "COUNT(DISTINCT CASE WHEN #{expr} THEN #{id} END) AS #{alias_name}"
    end

    scope :current_contract_holders_with_counts, lambda {
      current
        .joins(contract_holder_joins)
        .left_joins(:licences)
        .joins('LEFT JOIN schools AS licence_schools ON licence_schools.id = commercial_licences.school_id')
        .left_joins(:school_onboardings)
        .select(
          'commercial_contracts.contract_holder_type',
          'commercial_contracts.contract_holder_id',
          "#{contract_holder_name_sql} AS contract_holder_name",
          count_case('licence_schools.visible = TRUE AND licence_schools.data_enabled = FALSE',
                     'visible_not_data_enabled_count'),
          count_case('licence_schools.visible = TRUE AND licence_schools.data_enabled = TRUE',
                     'visible_data_enabled_count'),
          count_case(
            'school_onboardings.school_id IS NULL',
            'onboarding_count',
            id: 'school_onboardings.id'
          )
        )
        .group(
          'commercial_contracts.contract_holder_type', 'commercial_contracts.contract_holder_id',
          'schools.name', 'school_groups.name', 'funders.name'
        )
        .order(Arel.sql(contract_holder_name_sql))
    }

    def self.current_contract_holder_summaries
      current_contract_holders_with_counts.map do |row|
        visible_not = row.visible_not_data_enabled_count
        visible_yes = row.visible_data_enabled_count
        onboard     = row.onboarding_count

        {
          id: row.contract_holder_id,
          name: row.contract_holder_name,
          type: row.contract_holder_type,
          visible_not_data_enabled: visible_not,
          visible_data_enabled: visible_yes,
          onboardings: onboard,
          total: visible_not + visible_yes + onboard
        }
      end
    end

    def self.temporal_group_keys = %i[contract_holder_id contract_holder_type]

    def self.new_with_defaults(attributes)
      defaults = {
        start_date: Time.zone.today,
        end_date: Time.zone.today.next_year - 1.day,
        xero_account_code: ::Commercial::XeroAccountCode.find_by(code: 29)
      }.merge(attributes)
      new(defaults)
    end

    def self.as_renewal(original, chosen_type: nil)
      renewed_attributes = {
        comments: "Renewed from #{original.name}",
        end_date: original.end_date.next_year,
        start_date: original.end_date + 1.day,
        update_licences: true,
        licence_period: :contract,
        invoice_terms: :pro_rata
      }

      if chosen_type == :custom
        renewed_attributes[:licence_period] = :custom
        renewed_attributes[:invoice_terms] = :full
      end

      new(
        original.slice(
          :agreed_school_price,
          :contract_holder_type,
          :contract_holder_id,
          :licence_years,
          :number_of_schools,
          :product,
          :xero_account_code
        ).merge(
          renewed_attributes
        )
      )
    end

    def self.filtered(scope_name, date = nil)
      date = Date.parse(date) if date.present? && date.is_a?(String)
      scope = date.present? ? public_send(scope_name, date) : public_send(scope_name)
      scope.includes(:contract_holder, :product).by_start_date
    end

    # list of schools that might be added to this contract
    def candidate_schools
      return [] if contract_holder.is_a?(School)

      scope = if contract_holder.is_a?(Funder)
                School.visible.by_name
              else
                contract_holder.assigned_schools.visible.by_name
              end
      scope.where.not(id: schools)
    end

    def status_colour
      STATUS_COLOUR[status.to_sym]
    end

    def deletable?
      !invoiced?
    end

    def editable_attribute?(name)
      new_record? || editable_attributes.include?(name)
    end

    # Some fields of a contract cannot be changed once created, e.g. contract terms.
    # Some are safe to always be changed, e.g. name
    # Others cannot be changed once invoicing has started, e.g. agreed_school_price
    def editable_attributes
      fields = %i[comments name purchase_order_number number_of_schools updated_by_id xero_account_code_id]
      fields += %i[status] if provisional?
      fields += [:licence_years] if custom? && !invoiced?
      fields += [:invoice_terms] if contract? && !invoiced?
      fields += %i[agreed_school_price product_id start_date end_date] unless invoiced?
      fields
    end

    # Indicate whether changes to the contract should trigger updates to existing licences. Based on
    # user choice (:update_licences) and whether the saved changes indicate that an update is worthwhile.
    def cascade_updates_to_licences?
      update_licences? && licences.exists? && saved_changes.keys.intersect?(%w[start_date end_date status
                                                                               licence_years])
    end

    def as_range
      (start_date..end_date)
    end

    def custom_contract_length?
      custom? && licence_years > 1.0
    end

    def invoiced?
      invoices.any? || licences.invoiced.exists?
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

    def validate_invoice_terms
      return unless custom? && pro_rata?

      errors.add(:invoice_terms, 'invoice terms can only be full for a custom contract')
    end
  end
end
