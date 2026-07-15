# == Schema Information
#
# Table name: commercial_licences
#
#  id                    :bigint(8)        not null, primary key
#  comments              :text
#  end_date              :date             not null
#  invoice_reference     :string
#  school_specific_price :decimal(10, 2)
#  start_date            :date             not null
#  status                :enum             default("provisional"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contract_id           :bigint(8)        not null
#  created_by_id         :bigint(8)
#  school_id             :bigint(8)        not null
#  updated_by_id         :bigint(8)
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
    include Deletable

    self.table_name = 'commercial_licences'

    belongs_to :contract, class_name: 'Commercial::Contract'
    belongs_to :school

    delegate :product, to: :contract
    delegate :contract_holder, to: :contract

    before_save :move_to_pending_if_school_data_enabled

    LICENCE_STATUS = {
      provisional: 'provisional',
      confirmed: 'confirmed',
      pending_invoice: 'pending_invoice',
      invoiced: 'invoiced'
    }.freeze

    STATUS_COLOUR = {
      provisional: :warning,
      confirmed: :info,
      pending_invoice: :danger,
      invoiced: :success
    }.freeze

    def status_colour
      STATUS_COLOUR[status.to_sym]
    end

    enum :status, LICENCE_STATUS

    validates :start_date, :end_date, presence: true

    def self.temporal_group_keys = [:school_id]

    def self.filtered(scope_name, date = nil, school_group_id = nil)
      date = Date.parse(date) if date.present? && date.is_a?(String)
      scope = date.present? ? public_send(scope_name, date) : public_send(scope_name)

      if school_group_id.present?
        scope = scope.joins(school: :school_groupings)
                     .where(school_groupings: { school_group_id: school_group_id })
      end

      scope.includes(:contract, :school, school: :school_group, contract: :product)
           .by_start_date
    end

    scope :not_provisional, -> { where.not(status: :provisional) }

    # Calculate duration ignoring leap years
    def self.licence_period_days(period_start, period_end)
      real_days = (period_end - period_start).to_i + 1
      real_days - leap_days_between(period_start, period_end)
    end

    def dates_will_automatically_change?
      persisted? &&
        contract.custom? &&
        !school.data_enabled?
    end

    def deletable?
      !invoiced?
    end

    private_class_method def self.leap_days_between(period_start, period_end)
      (period_start.year..period_end.year).count do |year|
        Date.leap?(year) && Date.new(year, 2, 29).between?(period_start, period_end)
      end
    end

    private

    def destroy_error_message
      'Cannot delete an invoiced licence'
    end

    def move_to_pending_if_school_data_enabled
      return if pending_invoice? || invoiced?

      self.status = 'pending_invoice' if contract.confirmed? && school.data_enabled?
    end
  end
end
